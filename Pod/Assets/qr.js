function performBarcodeRequest(content)
{
//	document.location = content;
	//document.location = 'architectsdk://barcodeTrigger?content=' + content;
//    document.location = 'architectsdk://qrCodeTrigger?code=' + content;
    document.location = 'architectsdk://qrCodeTrigger?code=' + encodeURIComponent(content);
};