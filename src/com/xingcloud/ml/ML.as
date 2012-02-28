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
	 * ML是 Multi Language 的缩写，ML类是行云ML核心接口，通过静态的 <code>trans</code> 方法来获取平台服务。</br>
	 * <code>ML.trans("have a try");</code>
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
		 * 通过<code> ML.trans() </code>直接获取词句的翻译，如 <code>ML.trans("hello world")</code>
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
			
			var request:URLRequest = new URLRequest(API_URL + "/string/add") ;
			request.data = getURLVariables("data="+source) ; 
			request.method = URLRequestMethod.POST ;
			load(request, function(event:Event):void{addDebugInfo('"' + source + '" added.')}) ;
			
			return source ;
		}
		
		/**
		 * ML初始化。需要先登陆行云多语言管理系统创建翻译服务 http://i.xingcloud.com/service
		 * @param serviceName - String 服务名称，如 "my_ml_test"
		 * @param lang - String 目标语言，如 "en"
		 * @param apiKey - String ML分配的API密钥，如 "21f9a506b10062ea986483b794736e35"
		 * @param callBack - String 初始化完成的回调函数，如 <code>function onMLReady(){trace("ML ready")}</code>
		 * @see http://i.xingcloud.com/service 行云多语言管理系统
		 */
		static public function init(serviceName:String, lang:String, apiKey:String, callBack:Function=null):void
		{
			if(_serviceName && _serviceName.length > 0)
				return ;
			
			_serviceName = serviceName ;
			_apiKey = apiKey ;
			_callBack = callBack ;
			addDebugInfo("version 1.0.0.120226 initing...") ;
			
			var request:URLRequest = new URLRequest(API_URL+"/file/info") ;
			request.data = getURLVariables("file_path=xc_words.xml&lang="+lang) ; 
			request.method = URLRequestMethod.POST ;
			load(request, onFileInfoLoaded) ;
		}

		/*"status": "NO_WORD", "lang": "cn", "source_lang": "en",
		"translated": 0, "corpus": 1, "file_path": "xc_words.xml"
		"request_address": "http://119.254.88.196/ml_assdk_test/cn/default/xc_words.xml",*/
		static private function onFileInfoLoaded(event:Event):void
		{
			addDebugInfo("file info loaded: " + event.target.data) ;
			var info:Object = Json.decode(event.target.data) ;
			
			if(info && info.data && info.data["status"] == "COMPLETE")
				load(new URLRequest(info.data["request_address"]), onXMLLoaded) ;
			else
				_callBack && _callBack() ;
		}
	
		static private function onXMLLoaded(event:Event):void
		{
			var xml:XML = new XML(event.target.data) ;
			var list:XMLList = xml.children() ;
			addDebugInfo("file loaded, total words: " + list.length()) ;
			
			for each (var x:XML in list) 
				_db[x.source] = x.target ;
				
			_callBack && _callBack() ;
		}
		
		static private function getURLVariables(source:String=null):URLVariables
		{
			var variables:URLVariables = new URLVariables(source) ;
			variables.service_name = _serviceName ;
			variables.timestamp = new Date().time ;
			variables.hash = "md5(timestamp+apikey)" ;
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
		
		static private function addDebugInfo(info:String):void
		{
			trace("ML:", info) ;
			// call JSProxy.addDebugInfo(info) ;
		}
	}
}
