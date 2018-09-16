# ankleweightapp
Mac Menu Bar app to track the idle time of your smart ankle weight and cushion, and remind you to exercise






Photos

![App open screen](https://raw.githubusercontent.com/juhndu/ankleweightapp/master/photos/med.png)
![Settings](https://raw.githubusercontent.com/juhndu/ankleweightapp/master/photos/low%20set.png)
![Historical](https://raw.githubusercontent.com/juhndu/ankleweightapp/master/photos/hi%20hist.png)


Code


The app reads from the API endpoint of the smart ankle weights and the smart cushion, to see if the ankle weight is in motion and if the cushion is being sat on.
![API request](https://raw.githubusercontent.com/juhndu/ankleweightapp/master/photos/request.png)

Based on its readings, it determines the state - whether the user is exercising, sitting idly, or away, and updates the "idle bar" or "aggregateSeconds" accordingly. As "aggregateSeconds" reaches certain thresholds, the menu bar icon is updated, notifications are sent, and an SMS reminder can be sent as well using an IFTTT webhook.
![State update](https://raw.githubusercontent.com/juhndu/ankleweightapp/master/photos/state%20updates%20bar%20and%20icon.png)
![IFTTT](https://raw.githubusercontent.com/juhndu/ankleweightapp/master/photos/ifttt.png)
