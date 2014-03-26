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

    @label = UILabel.alloc.initWithFrame(CGRectZero)
    @label.text = "00000000000000000"
    @label.backgroundColor = UIColor.whiteColor.colorWithAlphaComponent(0.5)
    @label.sizeToFit
    @label.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)
    self.view.addSubview @label

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
            @label.text = $last_bar_code
            BW::HTTP.post("https://www.bookshare.io/books", payload: {isbn: $last_bar_code, token: "xX46qno10MkJW3895175mu8up54XXz3dAnO5VGwe"}) do |r|
              @label.text = "STORED"
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
