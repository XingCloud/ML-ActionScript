package com.xingcloud.ml
{
	import com.xingcloud.ml.suport.Json;
	import com.xingcloud.ml.suport.MD5;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.System;

	/**
	 * ML是 Multi Language 的缩写，ML类是行云ML核心接口，通过静态的 <code>trans</code> 方法来获取平台服务。</br>
	 * <code>ML.trans("translate me to the world");</code>
	 * @see #trans()
	 * @author XingCloudly
	 */
	public class ML
	{
		private static const API_URL:String = "http://i.xingcloud.com/api/v1" ;
		private static const XC_WORDS:String = "xc_words.json";
		private static var _apiKey:String ;
		private static var _serviceName:String;
		private static var _callBack:Function;
		private static var _sourceLang:String;
		private static var _targetLang:String;
		private static var _autoAddTrans:Boolean = false ;
		private static var _prefix:String = null ;
		private static var _snapshot:Object = {} ;
		private static var _db:Object = {};
		
		/**
		 * 不可实例化，尝试实例化会抛错。直接通过 <code>ML.trans(serviceName)</code> 来获取ML服务。
		 * @throws Error please access by ML.trans()!
		 * @see #trans()
		 */
		public function ML():void
		{
			throw new Error("ML: Please access by ML.trans()!");
		}
		
		/**
		 * ML初始化。需要先登陆行云管理系统创建多语言服务 http://p.xingcloud.com
		 * @param serviceName - String 服务名称，如 "my_ml_test"
		 * @param apiKey - String 行云多语言管理系统分配的API密钥，如 "21f...e35"
		 * @param sourceLang - String 原始语言，如 "cn"
		 * @param targetLang - String 目标语言，如 "en"，直接从行云传递给应用的flashVars里取得
		 * @param autoAddTrans - Boolean 是否自动添加未翻译词句到多语言服务器，默认为false
		 * @param callBack - Function 初始化完成的回调函数，如 <code>function onMLReady(){trace("ML ready")}</code>
		 * @see http://p.xingcloud.com 行云管理系统
		 */
		public static function init(serviceName:String, apiKey:String, 
									sourceLang:String, targetLang:String, 
									autoAddTrans:Boolean, callBack:Function):void
		{
			if(_serviceName && _serviceName.length > 0)
				return ; //多次初始化视而不见
			
			addDebugInfo("version 1.0.1.120322 initing...") ;
			_serviceName = serviceName ;
			_apiKey = apiKey ;
			_sourceLang = sourceLang ;
			_targetLang = targetLang ;
			_callBack = callBack ;
			_autoAddTrans = autoAddTrans ;
			
			loadFileSnapshot();
		}
		
		/**
		 * 通过原始语言资源地址获取目标语言地址（无缓存问题）。 需要初始化完成后才能正确响应。
		 * @param sourceUrl - String 原始语言资源地址
		 * @return String 目标语言资源地址（有防止缓存机制），如果未初始化将原地址返回
		 * @throws Error "ML.transUrl(sourceUrl) param sourceUrl is null"
		 */
		public static function transUrl(sourceUrl:String):String 
		{
			if(sourceUrl == null || sourceUrl.length == 0)
				throw new Error("ML.transUrl(sourceUrl) param sourceUrl is null") ;

			var targetUrl:String = sourceUrl ;
			var	vars:String = sourceUrl.substr(sourceUrl.indexOf("?") + 1) ;
			var	tail:String = sourceUrl.toLowerCase() ;
			
			if(sourceUrl.search(/http:\/\/f\.xingcloud\.com/i) != -1)
			{
				tail = tail.replace(_prefix+"/", "") ;
			}
			else
			{
				tail = tail.replace(/http:\/\//i, "") ;
				tail = tail.substr(tail.indexOf("/") + 1) ;
			}
			
			tail = tail.replace("?" + vars, "") ;
			addDebugInfo("tail=" + tail + " vars=" + vars) ;
			
			if(_snapshot[tail] && _prefix)
			{
				targetUrl = _prefix + "/" + tail + "?md5=" + _snapshot[tail] ;
				if (vars && vars.length < sourceUrl.length)
					targetUrl += "&" + vars ;
			}

			return targetUrl ;
		}
		
		/**
		 * 通过<code> ML.trans() </code>直接获取词句的翻译，如 <code>ML.trans("hello world")</code> </br>
		 * @param source - String soure 需要翻译的词句
		 * @return String 翻译后的词句
		 * @see http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455 行云ML在线文档
		 */
		public static function trans(source:String):String 
		{
			if(source == null || source.length == 0)
				return "" ;
			
			for (var key:String in _db) 
				if(key == source) return _db[key] ;
			
			if(_autoAddTrans)
			{
				var request:URLRequest = new URLRequest(API_URL + "/string/add") ;
				request.data = getURLVariables("data="+source) ; 
				request.method = URLRequestMethod.POST ;
				loadRequest(request, function(event:Event):void{addDebugInfo("add -> " + source)}) ;
			}
			return source ;
		}

		/**
		 * 加载文件快照。 
		 */
		private static function loadFileSnapshot():void
		{
			var request:URLRequest = new URLRequest(API_URL + "/file/snapshot") ;
			request.data = getURLVariables("locale=" + _targetLang) ;
			loadRequest(request, onFileSnapshotLoaded) ;
		}
		
		private static function onFileSnapshotLoaded(event:Event):void
		{
			addDebugInfo("file snapshot loaded: " + event.target.data) ;
			var json:String = event.target.data ;
			var response:Object = {} ;
			if(json && json.length > 0)
			{
				try { response = Json.decode(json) ; } 
				catch(error:Error) { addDebugInfo(error) ; }
			}
			_prefix = response["request_prefix"] ;
			_snapshot = response["data"] ? response["data"] : {} ;
			
			var xcWordsUrl:String = _prefix + "/" + XC_WORDS + "?" + _snapshot[XC_WORDS] ;
			loadRequest(new URLRequest(xcWordsUrl), onXCWordsLoaded) ;
		}
	
		private static function onXCWordsLoaded(event:Event):void
		{
			var json:String = event.target.data ;
			if(json == null || json.length == 0)
			{
				addDebugInfo("file loaded. file is empty.") ;
			}
			else
			{
				addDebugInfo("file loaded. file length: " + json.length) ;
				try { _db = Json.decode(json) ; } 
				catch (error:Error) { addDebugInfo(error) ; }
			}
			_callBack && _callBack() ;
		}
		
		private static function getURLVariables(source:String=null):URLVariables
		{
			var timestamp:Number = new Date().time ;
			var variables:URLVariables = new URLVariables(source) ;
			variables.service_name = _serviceName ;
			variables.timestamp = timestamp ;
			variables.hash = MD5.hash(timestamp+_apiKey) ;
			return variables ;
		}
		
		private static function loadRequest(request:URLRequest, onComplete:Function):void
		{
			System.useCodePage = false ;
			var	loader:URLLoader = new URLLoader() ;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError) ;
			loader.addEventListener(Event.COMPLETE, onComplete) ;
			loader.load(request) ;
		}
		
		private static function onLoadError(event:ErrorEvent):void
		{
			addDebugInfo("load error: " + event) ;
		}
		
		private static function addDebugInfo(info:Object):void
		{
			trace("ML:", info.toString()) ;
			// call JSProxy.addDebugInfo(info) ;
		}
	}
}
