package com.xingcloud.ml
{
	import com.xingcloud.ml.suport.Json;
	
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
	 * ML是 Multi Language 的缩写，ML类是行云ML核心接口，通过静态实例的 <code>trans</code> 方法来获取平台服务。如获取好友信息：</br>
	 * <code>ML.instance.trans("have a try");</code>
	 * @see #trans()
	 * @author XingCloudly
	 */
	public class ML
	{
		private static var _instance:ML = new ML() ; 
		private var API_URL:String = "http://i.xingcloud.com/api/v1" ;
		private var _apiKey:String ;
		private var _serviceName:String;
		private var _db:Object = {};
		private var _callBack:Function;
		
		/**
		 * ML实例，可以通过该静态实例，获取平台服务。
		 * @see #trans()
		 */
		public static function get instance():ML
		{
			return _instance;
		}
		
		/**
		 * 单例模式，无需显式调用。
		 * 直接通过 <code>ML.instance.trans(serviceName, params, callBack)</code> 来获取ML服务。
		 * @throws Error please access by ML.instance!
		 * @see #trans()
		 */
		public function ML():void
		{
			if (_instance)
				throw new Error("ML: Please access by ML.instance!");
		}
		
		/**
		 * 通过<code> ML.instance.trans() </code>do what，示例如：
		 * @param source - String soure 
		 * @return String transed
		 * @see http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455 行云ML在线文档
		 */
		public function trans(source:String):String 
		{
			if(source == null || source.length == 0)
				return "" ;
			
			for (var key:String in _db) 
			{
				if(key == source) return _db[key] ;
			}
			
			loadStringAdd(source) ;
			
			return source ;
		}
		
		private function loadStringAdd(string:String):void
		{
			var request:URLRequest = new URLRequest(API_URL + "/string/add") ;
			request.data = getURLVariables("data="+string) ; 
			request.method = URLRequestMethod.POST ;
			load(request, function(event:Event):void{addDebugInfo(string + " added.")}) ;
		}
		
		/**
		 * ML初始化。
		 * @throws Error ML: param "main" is null or has nonstage!
		 */
		public function init(serviceName:String, lang:String, apiKey:String, callBack:Function=null):void
		{
			_serviceName = serviceName ;
			_apiKey = apiKey ;
			_callBack = callBack ;
			addDebugInfo("initing...") ;
			
			var request:URLRequest = new URLRequest(API_URL+"/file/info") ;
			request.data = getURLVariables("file_path=xc_words.xml&lang="+lang) ; 
			request.method = URLRequestMethod.POST ;
			load(request, onFileInfoLoaded) ;
		}

		/*"status": "NO_WORD", "lang": "cn", "source_lang": "en",
		"translated": 0, "corpus": 1, "file_path": "xc_words.xml"
		"request_address": "http://119.254.88.196/ml_assdk_test/cn/default/xc_words.xml",*/
		private function onFileInfoLoaded(event:Event):void
		{
			addDebugInfo("file info loaded: " + event.target.data) ;
			var info:Object = Json.decode(event.target.data) ;
			
			if(info && info.data && info.data["status"] == "COMPLETE")
				load(new URLRequest(info.data["request_address"]), onXMLLoaded) ;
			else
				_callBack && _callBack() ;
		}
	
		private function onXMLLoaded(event:Event):void
		{
			var xml:XML = new XML(event.target.data) ;
			var list:XMLList = xml.children() ;
			addDebugInfo("file loaded, total words: " + list.length()) ;
			
			for each (var x:XML in list) 
			{
				_db[x.source] = x.target ;
			}
			_callBack && _callBack() ;
		}
		
		
		private function getURLVariables(source:String=null):URLVariables
		{
			var variables:URLVariables = new URLVariables(source) ;
			variables.service_name = _serviceName ;
			variables.timestamp = new Date().time ;
			variables.hash = "md5(timestamp+apikey)" ;
			return variables ;
		}
		
		private function load(request:URLRequest, onComplete:Function):void
		{
			System.useCodePage = false ;
			var	loader:URLLoader = new URLLoader() ;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError) ;
			loader.addEventListener(Event.COMPLETE, onComplete) ;
			loader.load(request) ;
		}
		
		private function onLoadError(event:ErrorEvent):void
		{
			addDebugInfo("load error: " + event) ;
		}
		
		private function addDebugInfo(info:String):void
		{
			trace("ML:", info) ;
			// call JSProxy.addDebugInfo(info) ;
		}
	}
}
