package
{
	import com.bit101.components.Text;
	import com.google.zxing.BarcodeFormat;
	import com.google.zxing.BinaryBitmap;
	import com.google.zxing.BufferedImageLuminanceSource;
	import com.google.zxing.DecodeHintType;
	import com.google.zxing.MultiFormatReader;
	import com.google.zxing.Result;
	import com.google.zxing.client.result.ParsedResult;
	import com.google.zxing.client.result.ResultParser;
	import com.google.zxing.common.HybridBinarizer;
	import com.google.zxing.common.flexdatatypes.HashTable;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.media.Camera;
	import flash.media.Video;
	
	[SWF(width="960", height="640")]
	public class ARMobileDemo extends Sprite
	{
		private var video:Video;
		private var resulttextarea:Text;
		private var myReader:MultiFormatReader;
		
		public function ARMobileDemo()
		{
			super();
			myReader = new MultiFormatReader();
			
			video = new Video();
			var camera:Camera = Camera.getCamera();
			if ((camera.width == -1) && ( camera.height == -1))
			{
				// no webcam seems to be attached -> hide videoDisplay
				video.width  = 0;
				video.height = 0;
			}
			else
			{
				// webcam detected
				
				// change the default mode of the webcam
				camera.setMode(350,350,5,true);
				video.width  = camera.width;
				video.height = camera.height;
				
				video.attachCamera(camera);
			}
			addChild(video);
			
			resulttextarea = new Text(this, video.x, video.y+video.height);
		}
		
		private function decodeSnapshot():void
		{
			var bmd:BitmapData = new BitmapData(this.video.width, this.video.height);
			bmd.draw(video);
			this.decodeBitmapData(bmd, this.video.width, this.video.height);
		}
		public function decodeBitmapData(bmpd:BitmapData, width:int, height:int, appendOutput:Boolean=false):void
		{
			// create the container to store the image width and height in
			var lsource:BufferedImageLuminanceSource = new BufferedImageLuminanceSource(bmpd);
			// convert it to a binary bitmap
			var bitmap:BinaryBitmap = new BinaryBitmap(new HybridBinarizer(lsource));
			// get all the hints
			var ht:HashTable = null;
			ht = this.getAllHints()
			var res:Result = null;
			try
			{
				// try to decode the image
				res = myReader.decode(bitmap,ht);
			}
			catch(e:*) 
			{
				// failed
				if (!appendOutput) 
				{
					this.resulttextarea.text = e.message;
				}
				else
				{
					this.resulttextarea.text += e.message;
				}
			}
			
			// did we find something?
			if (res == null)
			{
				if (!appendOutput)
				{
					// no : we could not detect a valid barcode in the image
					this.resulttextarea.text = "<<No decoder could read the barcode>>";
//					if (!this.bc_tryharder.selected)
//					{
//						this.resulttextarea.text = "<<No decoder could read the barcode : Retry with the 'Try Harder' setting>>";
//					}
				}
				else
				{
					this.resulttextarea.text += "Could not decode image";
				}
			}
			else
			{
				// yes : parse the result
				var parsedResult:ParsedResult = ResultParser.parseResult(res);
				// get a formatted string and display it in our textarea
				if (!appendOutput)
				{
					this.resulttextarea.text = parsedResult.getDisplayResult();
				}
				else
				{
					this.resulttextarea.text += parsedResult.getDisplayResult();
				}
			}
		}
		public function getAllHints():HashTable
		{
			// get all hints from the user
			var ht:HashTable = new HashTable();
			ht.Add(DecodeHintType.POSSIBLE_FORMATS,BarcodeFormat.QR_CODE);
			return ht;
		}
	}
}