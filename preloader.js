// Generated by CoffeeScript 1.7.1
(function() {
  Framer.Preloader = (function() {
    function Preloader() {
      var layer, _i, _len, _ref;
      this.imagesToLoad = [];
      _ref = Framer.CurrentContext._layerList;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        layer = _ref[_i];
        if (layer.image) {
          this.imagesToLoad.push(layer);
        }
      }
      this.imagesTotalCount = this.imagesToLoad.length;
      this.imagesLoadedCount = 0;
      this.loadingLayer = new Layer;
      this.loadingLayer.backgroundColor = '#222';
      this.loadingLayer.superLayer = Framer.Device.screen;
      this.loadingLayer.frame = Framer.Device.viewport.frame;
      this.loadingLayer.bringToFront();
      this.loadingText = new Layer({
        x: 100,
        y: 130,
        width: 400,
        height: 100,
        backgroundColor: 'transparent'
      });
      this.loadingText.style = {
        font: '100 48px Helvetica',
        color: '#999'
      };
      this.loadingText.html = "Hang tight";
      this.loadingText.superLayer = this.loadingLayer;
      this.loadingText.animation1 = this.loadingText.animate({
        properties: {
          x: 400
        },
        curve: 'linear',
        time: 20
      });
      this.loadingText.animation2 = this.loadingText.animation1.reverse();
      this.loadingText.animation1.on('end', (function(_this) {
        return function() {
          return _this.loadingText.animation2.start();
        };
      })(this));
      this.loadingText.animation2.on('end', (function(_this) {
        return function() {
          return _this.loadingText.animation1.start();
        };
      })(this));
      this.loadingBar = new Layer({
        x: 100,
        y: 200,
        width: 10,
        height: 2,
        backgroundColor: 'white'
      });
      this.loadingBar.superLayer = this.loadingLayer;
      this.tempLayer = new Layer({
        x: 0,
        y: 0,
        width: 750,
        height: 1334,
        backgroundColor: 'transparent'
      });
      this.tempLayer.superLayer = this.loadingLayer;
      this.tempLayer.sendToBack();
      Utils.delay(0.5, (function(_this) {
        return function() {
          return _this.imagesToLoad.forEach(function(layer, k) {
            var loader;
            layer.original = {
              superLayer: layer.superLayer,
              frame: layer.frame,
              opacity: layer.opacity,
              visible: layer.visible,
              index: layer.index,
              scale: layer.scale
            };
            layer.superLayer = _this.tempLayer;
            layer.scale = 1 / Math.max(layer.height / 1334, 1);
            layer.center();
            layer.opacity = 0.1;
            layer.visible = true;
            loader = new Image();
            loader.name = layer.image;
            loader.src = layer.image;
            loader.onload = function() {
              layer.superLayer = layer.original.superLayer;
              layer.frame = layer.original.frame;
              layer.opacity = layer.original.opacity;
              layer.visible = layer.original.visible;
              layer.index = layer.original.index;
              layer.scale = layer.original.scale;
              console.log("Preloader: OK " + layer.image);
              return _this.imagesLoadedCount++;
            };
            return loader.onerror = function() {
              layer.superLayer = layer.original.superLayer;
              layer.frame = layer.original.frame;
              layer.opacity = layer.original.opacity;
              layer.visible = layer.original.visible;
              layer.index = layer.original.index;
              layer.scale = layer.original.scale;
              console.log("Preloader: Err " + layer.image);
              return _this.imagesLoadedCount++;
            };
          });
        };
      })(this));
      this.loadingInterval = setInterval((function(_this) {
        return function() {
          if (_this.imagesLoadedCount >= _this.imagesTotalCount) {
            _this.loadingLayer.animation1 = _this.loadingLayer.animate({
              properties: {
                opacity: 0
              },
              curve: 'bezier-curve',
              time: 0.2
            });
            _this.loadingLayer.animation1.on('end', function() {
              return _this.loadingLayer.visible = false;
            });
            return clearInterval(_this.loadingInterval);
          } else {
            return _this.loadingBar.animate({
              properties: {
                width: Utils.modulate(_this.imagesLoadedCount, [0, _this.imagesTotalCount], [0, 550])
              },
              curve: 'bezier-curve',
              time: 0.1
            });
          }
        };
      })(this), 200);
    }

    return Preloader;

  })();

}).call(this);
