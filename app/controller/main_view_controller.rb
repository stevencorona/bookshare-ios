class MainViewController < UIViewController

  @last_bar_code = nil

  def viewDidLoad
    super
    self.view.backgroundColor = UIColor.whiteColor
    setupCapture()
    true
  end

  def setupCapture
    @session = AVCaptureSession.alloc.init
    @session.sessionPreset = AVCaptureSessionPresetHigh

    @device = AVCaptureDevice.defaultDeviceWithMediaType AVMediaTypeVideo
    @error = Pointer.new('@')
    @input = AVCaptureDeviceInput.deviceInputWithDevice @device, error: @error

    @previewLayer = AVCaptureVideoPreviewLayer.alloc.initWithSession(@session)
    @previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    layerRect = self.view.layer.bounds
    @previewLayer.bounds = layerRect
    @previewLayer.setPosition(CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect)))
    self.view.layer.addSublayer(@previewLayer)

    @queue = Dispatch::Queue.new('camQueue')
    @output = AVCaptureMetadataOutput.alloc.init
    @output.setMetadataObjectsDelegate self, queue: @queue.dispatch_object

    @session.addInput @input
    @session.addOutput @output
    @output.metadataObjectTypes = [ AVMetadataObjectTypeEAN13Code ]

    @session.startRunning
    NSLog "session running: #{@session.running?}"
    true
  end

  def captureOutput(captureOutput, didOutputMetadataObjects: metadataObjects, fromConnection: connection)
        if metadataObjects[0] != nil

          string = metadataObjects[0].stringValue

          return if @last_bar_code == string
          @last_bar_code = string
          $last_bar_code = string
          NSLog "#{string}"

          action = lambda do
            runLoop = NSRunLoop.currentRunLoop

            BW::HTTP.post("http://10.0.1.6:5000/books", payload: {isbn: $last_bar_code}) do |r|
              NSLog("Fetched Google!")
            end

            runLoop.run
          end

          thread = NSThread.alloc.initWithTarget action, selector:"call", object:nil
          thread.start

          NSLog "Here tho"
        end
      true
  end
end
