# Advanced iOS AT4: Group Project 

## 'Travel Journal' App

## Github Repository Link: https://github.com/byro23/Travel-Journal-App

## Instructions

### Package Dependencies

All package dependencies should automatically install upon after cloning the repository.
If the dependencies do not install, please use the Swift Package Manager to install the following:

- Firebase iOS SDK ``` https://github.com/firebase/firebase-ios-sdk ``` (With FirebaseFirestore & FirebaseAuth added to target)

## App Description

### MapView

'Travel Journal' app allows users to write journals based on location. The user can create journals but tapping anywhere on the map and following the dialog menu prompt. 

**Picture here**

After tapping the 'create journal' option in the prompt, the user will be presented the following screen.

### NewJournalView

**Picture here**

This view allows the user to enter a journal title, the date of the adventure, a journal entry, attach image files and fill in the address. There are also auto complete suggestions that allows the user to quickly fill in the address information based on nearby destinations.

**Upload image picture here**

**Auto complete pictures here**

Once the journal is submitted, the user can tap on the map annotation to revisit it. However, the more desirable way to view their journals is via the 'journals' tab:

### JournalsView

**Journal tab picture**.

From here the user can search, filter or re-order their journals:

**picture here**

The user can also navigate to a more detailed view of a specific journal by tapping on it in the list and selecting 'View Journal' or go to it's specific location on the map by tapping 'Go to position on map: 

### JournalDetailsView

If the user taps view journal, they will be presented with a visually pleasing view of all journal information, including images:

**Screenshot here**

The last tab of app is settings view. This is a simple administrative view which lets the user signout and update their personal details, such as email, name and password:

**Image here**

Lastly to provide the user to authenticate and register with the platform, we have Login and Registration views:

### LoginView

### RegistrationView

