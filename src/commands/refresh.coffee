define ["arbiter"], (arbiter) ->
  (command, args) ->
    if command == "\\refresh"
      id = ""
      for i in [0..20]
        id += Math.floor(Math.random()*10).toString()
      text = """<script>
  if (!localStorage.refresh#{id}) {
    localStorage.refresh#{id} = true;

    var keithWidth = window.innerWidth * 0.7;
    var megaKeith = document.createElement("img");
    megaKeith.src = "./megakeith/megaKeith.gif";
    megaKeith.style = "position: absolute; bottom: 0px; z-index: 10000; left: " + (window.innerWidth - keithWidth) * 0.5 + "px; width: " + keithWidth + "px;"
    document.body.appendChild(megaKeith);
    var audio = document.createElement("audio");
    audio.src = "./megakeith/megaKeith.mp3";
    audio.volume = "0.1";
    audio.autoplay = "autoplay";
    document.body.appendChild(audio);

    window.setInterval(function () {
      var smokeId = "";
      for (var i = 0; i < 20; i++) {
        smokeId += Math.floor(Math.random() * 10).toString();
      }
      var smokeKeyFrames = "@keyframes Smoke" + smokeId + " { 0% { opacity: 0; bottom: -200px; transform: rotate(" + Math.random() * 360 + "deg); } 80% { opacity: 0.8; } 100% { opacity: 0; transform: rotate(" + Math.random() * 360 + "deg); bottom: 50px; }"
      var smokeStyle = document.createElement("style");
      smokeStyle.type = "text/css";
      smokeStyle.appendChild(document.createTextNode(smokeKeyFrames));
      document.head.appendChild(smokeStyle);
      var smoke = document.createElement("img");
      smoke.src = "./megakeith/smoke" + (Math.floor(Math.random() * 5) + 1) + ".png";
      smoke.style = "position: absolute; left: " + Math.random() * window.innerWidth + "px; animation: Smoke" + smokeId + " 3s; opacity: 0; z-index: 50000;"
      document.body.appendChild(smoke);
    }, 100)

    window.setTimeout(function () {
      if (window.nodeRequire) {
        var remote = nodeRequire('remote');
        var win = remote.getCurrentWindow();
        win.webContents.session.clearCache(function() {
          location.reload(true);
        });
      } else {
        location.reload(true);
      }
    }, 15000)
  }
</script>"""
      arbiter.publish "messages/send", { text: text, author: localStorage.displayName }
