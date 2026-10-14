### Firebase 
Adding Firebase to a Flutter app
Firebase Console setup
Using Firebase CLI to add Firebase to your application
Using FlutterFire CLI to generate Firebase config in Dart
Adding Firebase Authentication to your Flutter app
Firebase Authentication setup in the console
Adding Email and Password sign in with the firebase_ui_auth package
Adding user registration with the firebase_ui_auth package
Adding a ‘Forgot password?' page
Adding Google Sign-in with firebase_ui_auth
Configuring your app to work with multiple sign-in providers.
Adding a user profile screen to your application with the firebase_ui_auth package



Installing the firebase client using the  following command
install it with:

# brew update
# brew install firebase-cli
Then verify:

# firebase --version
Authenticate:

firebase login
That should open your browser for Google authentication. Then confirm that your projects are visible:

firebase projects:list
For upgrades later:

# brew update
# brew upgrade firebase-cli


# then we use flutterfire_cli which is built upon the firebase 