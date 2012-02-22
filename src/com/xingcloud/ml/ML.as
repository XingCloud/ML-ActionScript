package com.xingcloud.ml
{
	/**
	 * ML是 Multi Language 的缩写，ML类是行云ML核心接口，通过静态实例的 <code>trans</code> 方法来获取平台服务。如获取好友信息：</br>
	 * <code>ML.instance.trans("get_friends", {type:"all"}, onGetFriends);</code>
	 * @see #trans()
	 * @author XingCloudly
	 */
	public class ML
	{
		private static var _instance:ML = new ML() ; 

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
		 * ML初始化。
		 * @throws Error ML: param "main" is null or has nonstage!
		 */
		public function init():void
		{
			
		}
		
		/**
		 * 通过<code> ML.instance.trans() </code>do what，示例如：
		 * <ul>
		 * <li>xxx<code>trans("xxx");</code></li>
		 * <li>详情及更新 http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455</li>
		 * </ul>
		 * 下面参数介绍以获取用户好友信息为例。
		 * @param serviceName - String 服务名称，如 <code>"get_friends"</code> 
		 * @return String transed
		 * @see http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455 行云ML在线文档
		 */
		public function trans(source:String):String 
		{
			
			return "" ;
		}
	}
}
