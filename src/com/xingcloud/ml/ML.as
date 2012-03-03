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
		static private const API_URL:String = "http://i.xingcloud.com/api/v1" ;
		static private var _apiKey:String ;
		static private var _serviceName:String;
		static private var _callBack:Function;
		static private var _db:Object = {};
		static private var _autoAddTrans:Boolean = false ;
		
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
		 * 通过<code> ML.trans() </code>直接获取词句的翻译，如 <code>ML.trans("hello world")</code> </br>
		 * @param source - String soure 需要翻译的词句
		 * @return String transed 翻译后的词句
		 * @see http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455 行云ML在线文档
		 */
		static public function trans(source:String):String 
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
				load(request, function(event:Event):void{addDebugInfo("add -> " + source)}) ;
			}
			return source ;
		}
		
		/**
		 * ML初始化。需要先登陆行云多语言管理系统创建翻译服务 http://i.xingcloud.com/service
		 * @param serviceName - String 服务名称，如 "my_ml_test"
		 * @param apiKey - String 行云多语言管理系统分配的API密钥，如 "21f...e35"
		 * @param sourceLang - String 原始语言，如 "cn"
		 * @param targetLang - String 目标语言，如 "en"，如果与原始语言相同，则不翻译直接原文返回
		 * @param autoAddTrans - Boolean 是否自动添加未翻译词句到多语言服务器，默认为false
		 * @param callBack - Function 初始化完成的回调函数，如 <code>function onMLReady(){trace("ML ready")}</code>
		 * @see http://i.xingcloud.com/service 行云多语言管理系统
		 */
		static public function init(serviceName:String, apiKey:String, 
									sourceLang:String, targetLang:String, 
									autoAddTrans:Boolean=false, callBack:Function=null):void
		{
			if(_serviceName && _serviceName.length > 0)
				return ; //多次初始化视而不见
			
			addDebugInfo("version 1.0.0.120303 initing...") ;
			_serviceName = serviceName ;
			_apiKey = apiKey ;
			_callBack = callBack ;
			_autoAddTrans = autoAddTrans ;
			
			if(sourceLang == targetLang)
			{
				addDebugInfo("init stopped.") ;
				_autoAddTrans = false ;
				_callBack && _callBack() ;
			}
			else
			{
				var request:URLRequest = new URLRequest(API_URL+"/file/info") ;
				request.data = getURLVariables("file_path=xc_words.json&locale="+targetLang) ;
				load(request, onFileInfoLoaded) ;
			}
		}

		/*"status": "COMPLETE","source": "en","target": "cn","file_path": "xc_words.json",
		"length": 2,"source_words_count": 0,"human_translated": 0,"machine_translated": 0,
		"request_address": "http://119.254.88.196/ml_assdk_test/cn/default/xc_words.json",
		"md5": "99914b932bd37a50b983c5e7c90ae93b"*/
		static private function onFileInfoLoaded(event:Event):void
		{
			addDebugInfo("file info loaded: " + event.target.data) ;
			var info:Object = Json.decode(event.target.data) ;
			
			if(info && info.data && int(info.data["source_words_count"]) != 0)
				load(new URLRequest(info.data["request_address"]), onFileLoaded) ;
			else
				_callBack && _callBack() ;
		}
	
		static private function onFileLoaded(event:Event):void
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
				catch (error:Error) {}
			}
			_callBack && _callBack() ;
		}
		
		static private function getURLVariables(source:String=null):URLVariables
		{
			var timestamp:Number = new Date().time ;
			var variables:URLVariables = new URLVariables(source) ;
			variables.service_name = _serviceName ;
			variables.timestamp = timestamp ;
			variables.hash = MD5.hash(timestamp+_apiKey) ;
			return variables ;
		}
		
		static private function load(request:URLRequest, onComplete:Function):void
		{
			System.useCodePage = false ;
			var	loader:URLLoader = new URLLoader() ;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError) ;
			loader.addEventListener(Event.COMPLETE, onComplete) ;
			loader.load(request) ;
		}
		
		static private function onLoadError(event:ErrorEvent):void
		{
			addDebugInfo("load error: " + event) ;
		}
		
		static private function addDebugInfo(info:Object):void
		{
			trace("ML:", info.toString()) ;
			// call JSProxy.addDebugInfo(info) ;
		}
	}
}
