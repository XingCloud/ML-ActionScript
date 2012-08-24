package com.xingcloud.ml
{
	import com.xingcloud.suport.Json;
	import com.xingcloud.suport.MD5;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * ML是 Multi-Language 的缩写，ML类是行云多语言服务核心接口，
	 * 通过静态的 <code>ML.trans(source); ML.transUrl(sourceUrl);</code> 方法来获取服务。
	 * @author XingCloudly
	 */
	public class ML
	{
		private static const VERSION:String = "version 2.0.1.120822" ;
		private static var _serviceName:String = null ;
		private static var _apiKey:String = null ;
		private static var _sourceLang:String = null ;
		private static var _targetLang:String = null ;
		private static var _callBack:Function = null ;
		
		private static var _prefix:String = null ;
		private static var _snapshot:Object = {} ;
		private static var _db:Object = {};
		private static var _initTimeOut:int = 5000 ;
		private static var _initTimeOutId:int = int.MAX_VALUE;
		private static var _transUrlCount:int = 0 ;
		private static var _useTrans:Boolean = false ;
		private static var _useSourceHost:Boolean = false ;
		
		/**
		 * ML初始化回调后，可以用通过snapshotLoaded判断是否初始化成功。
		 */
		public static var snapshotLoaded:Boolean = false ;
		
		/**
		 * 不可实例化，尝试实例化会抛错。直接通过静态的 <code>ML.trans(source); ML.transUrl(sourceUrl);</code> 方法来获取服务。
		 * @throws Error please access by ML.trans() or ML.transUrl()!
		 * @see #trans() trans(source) 翻译词句
		 * @see #transUrl() transUrl(sourceUrl) 翻译URL
		 */
		public function ML():void
		{
			throw new Error("please access by ML.trans() or ML.transUrl()!");
		}
		
		/**
		 * 使用本接口直接获取词句的翻译，需要初始化前配置<code> ML.useTrans = true; </code> 
		 * 示例如 <code>ML.trans("世界你好");</code> 
		 * @param source - String soure 需要翻译的词句，如 "世界你好"
		 * @return String 翻译后的词句，如 "hello world"
		 * @see http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455 行云ML在线文档
		 */
		public static function trans(source:String):String 
		{
			if (source == null || source.length == 0)
				return "" ;
			
			for (var key:String in _db) { if (key == source) 
				return _db[key] ;
			}
			
			if (_useTrans)
			{
				var url:String = "http://i.xingcloud.com/api/v1/string/add";
				var request:URLRequest = new URLRequest(url) ;
				request.data = getURLVariables("data=" + encodeURI(source)) ; 
				request.method = URLRequestMethod.POST ;
				loadRequest(request, function(e:Event):void{addDebugInfo("add -> " + source)}) ;
			}
			return source ;
		}
		
		/**
		 * 通过 原始语言地址 获取 目标语言地址。必须使用该方法处理应用中的多语言资源地址，理由如下：
		 * <li>直接通过初始化配置的目标语言获取地址，代码逻辑与语言无关。</li>
		 * <li>目标资源地址携带资源文件版本标识xcv，享受CDN加速而无需担心缓存。</li>
		 * @param sourceUrl - String 原始语言资源地址
		 * @return targetUrl - String 目标语言资源地址
		 * @throws Error "ML.transUrl(sourceUrl) param sourceUrl is null"
		 */
		public static function transUrl(sourceUrl:String):String 
		{
			_transUrlCount++ ;
			addDebugInfo("transUrl " + _transUrlCount + " sourceUrl " + sourceUrl) ; 
			if (sourceUrl == null || sourceUrl.length == 0)
				throw new Error("ML.transUrl(sourceUrl) param sourceUrl is null") ;
			
			if (_prefix == null || _prefix.length < 13) // 13 : magic number:)
				return sourceUrl ;
			
			if (_sourceLang == _targetLang && !_useSourceHost) 
				return sourceUrl ;
			
			var tail:String = sourceUrl.replace(/\w*:\/\//i, "") ;
			var xcv:String = _snapshot[tail] ;
			var targetUrl:String = _prefix + "/" + tail ;
			if (targetUrl.indexOf("xcv=") == -1 && xcv)
			{
				if (targetUrl.indexOf("?") == -1) targetUrl += "?xcv=" + xcv ;
				else targetUrl += "&xcv=" + xcv ;
			}
			addDebugInfo("transUrl " + _transUrlCount + " tragetUrl " + targetUrl) ; 
			
			return targetUrl ;
		}
		
		/**
		 * 在初始化前设置，初始化最长等待callBack时间，单位毫秒，默认为5000毫秒。设置范围200-20000毫秒。 
		 */
		public static function set initTimeOut(timeOut:int):void
		{
			_initTimeOut = (timeOut >= 200 && timeOut <= 20000) ? timeOut : _initTimeOut ;
		}
		
		/**
		 * 在初始化前设置，源语言资源是否使用行云CDN（注意是源语言资源），默认为false不使用。
		 */
		public static function set useSourceHost(useSourceHost:Boolean):void
		{
			_useSourceHost = useSourceHost ;
		}
		
		/**
		 * 在初始化前设置，是否启用 ML.trans(source)，默认为关闭，以加速初始化速度。
		 */
		public static function set useTrans(useTrans:Boolean):void
		{
			_useTrans = useTrans ;
		}
		
		/**
		 * ML初始化。需要先登陆行云管理系统创建多语言服务 http://p.xingcloud.com
		 * @param serviceName - String 行云多语言管理系统配置的服务名称，如 "ml-test"
		 * @param apiKey - String 行云多语言管理系统分配的API密钥，如 "a4a3c891f47636a279b722c59270c452"
		 * @param sourceLang - String 原始语言，如 "cn"
		 * @param targetLang - String 目标语言，如 "en"，直接从应用的flashVars里取得
		 * @param callBack - Function 初始化完成的回调方法，如 <code>private function onMLReady(){trace("ML ready");}</code>
		 * @see http://p.xingcloud.com 行云管理系统
		 */
		public static function init(serviceName:String, apiKey:String, 
									sourceLang:String, targetLang:String, 
									callBack:Function):void
		{
			if (_serviceName && _serviceName.length > 0)
				return ; //多次初始化视而不见
			
			addDebugInfo(VERSION + " initing...") ;
			addDebugInfo([serviceName, apiKey, sourceLang, targetLang, callBack]) ;
			_serviceName = serviceName ;
			_apiKey = apiKey ;
			_sourceLang = sourceLang ;
			_targetLang = targetLang || sourceLang ;
			_callBack = callBack ;
			
			loadSnapshot();
			_initTimeOutId = setTimeout(onSnapshotLoaded, _initTimeOut, null) ;
		}
		
		/**
		 * 加载文件快照。 
		 */
		private static function loadSnapshot():void
		{
			var url:String = "http://i18n.xingcloud.com/" + _serviceName + "/" + _targetLang + "/v2_snapshot";
			var request:URLRequest = new URLRequest(url) ;
			request.data = getURLVariables("locale=" + _targetLang) ;
			loadRequest(request, onSnapshotLoaded, onSnapshotError) ;
		}
		
		/**
		 * 如果失败一直重试，直至加载成功或者超时。 
		 */
		private static function onSnapshotError(event:Event):void
		{
			addDebugInfo("load snapshot error: " + event) ;
			if (_initTimeOutId == int.MAX_VALUE) checkCallBack() ;
			else setTimeout(loadSnapshot, 1000) ;
		}
		
		/**
		 * 处理保存文件快照。如果正常加载完成，则尝试保存到cookie；如果超时，则尝试读取cookie。 
		 */
		private static function onSnapshotLoaded(event:Event):void
		{
			var json:String = event ? event.target.data : null ;
			var len:int = json ? json.length : 0 ;
			var lso:SharedObject = SharedObject.getLocal("xc_ml_snapshot") ;
			if (json && len > 0)
			{
				addDebugInfo("snapshot loaded. try to write cookie...") ;
				if (len < 128000 && json.charAt(len-1) == "}")
				{
					var writer:ByteArray = new ByteArray() ;
					writer.writeObject(json) ;
					writer.compress() ;
					lso.data[_serviceName] = writer ;
					try { lso.flush(writer.length); addDebugInfo("writed! size=" + (writer.length>>10) + " KB"); } 
					catch (error:Error) { addDebugInfo("failed! " + error);} 
				}
			}
			else 
			{
				addDebugInfo("snapshot load timeout. try to read cookie...") ;
				try {
					var reader:ByteArray = lso.data[_serviceName] ;
					reader.uncompress() ;
					json = reader.readObject() ;
					addDebugInfo("cookie read.") ;
				} 
				catch(error:Error) { 
					addDebugInfo("cookie not found.") ;
				}
			}
			
			len = json ? json.length : 0 ;
			if (json && len > 0)
			{
				addDebugInfo("snapshot decode length=" + len) ;
				var response:Object = {} ;
				try { response = Json.decode(json) ; } 
				catch (error:Error) { addDebugInfo("snapshot decode error: " + error) ; }
				
				_prefix = response["request_prefix"] ;
				_snapshot = response["data"] ;
				snapshotLoaded = Boolean(_prefix && _snapshot) ; 
			}
			else addDebugInfo("snapshot is empty. ATTENTION! check init params!") ;
			
			clearTimeout(_initTimeOutId) ;
			_initTimeOutId = int.MAX_VALUE ;
			
			if (event == null) checkCallBack() ;
			if (_useTrans) loadXCWords() ;
			else checkCallBack() ;
		}
		
		private static function loadXCWords():void
		{
			if (_useTrans && _prefix)
			{
				addDebugInfo("useTrans to load xc_words...") ;
				var xcWords:String = "xc_words.json" ;
				var xcWordsUrl:String = _prefix + "/" + xcWords + "?" + (_snapshot[xcWords]||Math.random()) ;
				loadRequest(new URLRequest(xcWordsUrl), onXCWordsLoaded) ;
			}
			else addDebugInfo("snapshot is empty, load xc_words skip.") ;
		}
		
		private static function onXCWordsLoaded(event:Event):void
		{
			var json:String = event.target.data ;
			if (json && json.length > 0)
			{
				addDebugInfo("xc_words loaded. file length=" + json.length) ;
				try { _db = Json.decode(json) ; } 
				catch (error:Error) { addDebugInfo("xc_words decode error: " + error) ; }
			}
			else addDebugInfo("xc_words loaded. file is empty.") ;
			
			checkCallBack() ;
		}
		
		private static function getURLVariables(source:String=null):URLVariables
		{
			var timestamp:Number = new Date().time ;
			var variables:URLVariables = new URLVariables(source) ;
			variables.timestamp = timestamp ;
			variables.service_name = _serviceName ;
			variables.hash = MD5.hash(timestamp+_apiKey) ;
			return variables ;
		}
		
		private static function loadRequest(request:URLRequest, onComplete:Function, onError:Function=null):void
		{
			System.useCodePage = false ;
			onError ||= onLoadError ; 
			var	loader:URLLoader = new URLLoader() ;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError) ;
			loader.addEventListener(Event.COMPLETE, onComplete) ;
			loader.load(request) ;
		}
		
		private static function onLoadError(event:Event):void
		{
			addDebugInfo("load error: " + event) ;
			checkCallBack() ;
		}
		
		private static function checkCallBack():void
		{
			_callBack && addDebugInfo("inited.") ;
			_callBack && _callBack() ;
			_callBack = null ;
		}
		
		private static function addDebugInfo(...info):void
		{
			trace("ML:", info.join(" ")) ;
			// call JSProxy.addDebugInfo(info) ;
		}
	}
}