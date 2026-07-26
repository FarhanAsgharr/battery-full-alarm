/*
  The hero animation: charge the meter to 100%, then let the phone speak — cycling
  through the four languages the app actually supports, switching text direction for
  Urdu and Arabic.

  Everything degrades safely: with reduced motion the meter jumps straight to 100 and
  the sentence cycles without the climb.
*/
(function () {
  "use strict";

  var meter = document.getElementById("meter");
  var fill = document.getElementById("meterFill");
  var label = document.getElementById("meterLabel");
  var speech = document.getElementById("speech");
  var speechLang = document.getElementById("speechLang");
  var speechLine = document.getElementById("speechLine");

  if (!meter || !fill || !label || !speech) return;

  var CIRCUMFERENCE = 2 * Math.PI * 50;
  fill.style.strokeDasharray = String(CIRCUMFERENCE);
  fill.style.strokeDashoffset = String(CIRCUMFERENCE);

  // The same announcement the app ships with, in each supported language.
  var LINES = [
    {
      code: "en",
      dir: "ltr",
      name: "English",
      text: "Muhammad, your phone battery is fully charged. Please remove the charger."
    },
    {
      code: "ur",
      dir: "rtl",
      name: "اردو · Urdu",
      text: "محمد، آپ کے فون کی بیٹری مکمل چارج ہو گئی ہے۔ براہِ کرم چارجر نکال دیں۔"
    },
    {
      code: "ar",
      dir: "rtl",
      name: "العربية · Arabic",
      text: "محمد، بطارية هاتفك مشحونة بالكامل. يرجى فصل الشاحن."
    },
    {
      code: "hi",
      dir: "ltr",
      name: "हिन्दी · Hindi",
      text: "मुहम्मद, आपके फ़ोन की बैटरी पूरी तरह चार्ज हो गई है। कृपया चार्जर निकाल दें।"
    }
  ];

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var index = 0;
  var cycleTimer = null;

  function setMeter(percent) {
    fill.style.strokeDashoffset = String(CIRCUMFERENCE * (1 - percent / 100));
    label.textContent = percent + "%";
    meter.classList.toggle("is-full", percent >= 100);
  }

  function show(entry) {
    speech.setAttribute("lang", entry.code);
    speech.setAttribute("dir", entry.dir);
    speechLang.textContent = entry.name;
    speechLine.textContent = entry.text;
  }

  function startCycling() {
    speech.classList.remove("is-idle");
    show(LINES[0]);
    cycleTimer = window.setInterval(function () {
      index = (index + 1) % LINES.length;
      speechLine.style.opacity = "0";
      window.setTimeout(function () {
        show(LINES[index]);
        speechLine.style.opacity = "";
      }, reduceMotion ? 0 : 260);
    }, 3800);
  }

  function charge() {
    if (reduceMotion) {
      setMeter(100);
      startCycling();
      return;
    }
    // Climb in a few uneven steps — a real charge does not fill linearly.
    var stops = [64, 82, 93, 98, 100];
    var at = 0;
    setMeter(41);
    (function step() {
      if (at >= stops.length) {
        window.setTimeout(startCycling, 420);
        return;
      }
      setMeter(stops[at]);
      at += 1;
      window.setTimeout(step, at === stops.length ? 900 : 640);
    })();
  }

  // Only run once the hero is actually on screen.
  if ("IntersectionObserver" in window) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          observer.disconnect();
          window.setTimeout(charge, 260);
        }
      });
    }, { threshold: 0.35 });
    observer.observe(meter);
  } else {
    charge();
  }

  // Stop the loop when the tab is hidden; nothing here is worth a background timer.
  document.addEventListener("visibilitychange", function () {
    if (document.hidden && cycleTimer) {
      window.clearInterval(cycleTimer);
      cycleTimer = null;
    } else if (!document.hidden && !cycleTimer && !speech.classList.contains("is-idle")) {
      startCycling();
    }
  });
})();
