Atmos iOS
---------------
The Atmos iOS app is an open source project for crowdsourcing weather data on iOS devices. The Atmos iOS app utilizes any available sensor found on an iPhone device (e.g. pressure sensor) for collecting weather related sensory input. Additionally, users can manually enter their own observations about both current and future weather conditions. The collected data is clustered by location, centrally processed, and loaded back into the Atmos iOS app for informing mobile users about weather conditions in places of interest. Existing apps in the area of crowd-sourced weather rely only on automated sensor capture to estimate current weather. A few applications optionally support using user input for verifying the accuracy of sensor data. However, our own research shows that users can be remarkably accurate when describing weather with a mobile app such as Atmos iOS, in particular when estimating current temperature, weather phenomena and wind intensity. Moreover, existing weather models often prove unreliable in areas known for their microclimates, such as mountainous valleys, mostly due to the reduced spatial resolution of fixed weather stations. Also, to the best of our knowledge, there is no other approach that is able to utilize the potential of expert users to predict short-term weather conditions (e.g. farmers or fishermen). Atmos iOS app serves as the counterpart of already deployed Atmos android app and Atmos public display app, into what we call “Atmos ecosystem”. Eventually, we envision Atmos ecosystem will offer a particular advantage for weather forecasting in places with microclimates, where current weather models prove insufficient. Currently, we are employing machine-learning algorithms for efficiently combining both human input and sensor data and generating our own hybrid weather models. Our approach utilizes the power of crowds, individually (mobile devices) and collectively (public displays), combining both explicit (human input) and implicit (automated sensor readings) sampling to significantly improve the accuracy of weather forecasting in areas with challenging climatic conditions. For more information about the project visit myweather.mobi. The Atmos iOS app will be soon available on the App Store.

Features
---------------
  - Collects pressure, acceleration, magnetic field sensor measurements
  - Collects user observations about current weather conditions in terms of current temperature, current weather phenomena and current wind intensity
  - Collects user predictions about future weather conditions in terms of future temperature, future weather phenomena and future wind intensity
  - Provides user generated information about weather current and future weather conditions in places of interest

Documentation
---------------
All data collected is anonymous and publicly available via the Atmos API.

    
License
---------------
EUPL (European Union Public License) https://en.wikipedia.org/wiki/European_Union_Public_Licence

  [Paul Schlyter]: http://stjarnhimlen.se/english.html
  [1.0]: https://github.com/erndev/EDSunriseSet/tree/1.0
  [myweather.mobi]: http://myweather.mobi
  [Atmos API]: http://beja.m-iti.org/web/?q=node/10