# StudyNotes

## Table of Contents
1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview
### Description
This app lets anyone learn new things/revise whatever they have learned depending upon how frequent they want. This app sends push notifications in a certain interval of time (that can be set by users like every 45 minutes from 9 am to 5 pm). 


### App Evaluation
- **Category:** Learning/Productivity
- **Mobile:** The app will be primarly focused for mobile use as it uses push notifications.
- **Story:** Personally, I like to learn something new everyday, and this app lets anyone learn new things/revise whatever they have learned depending upon how frequent they want.
- **Market:** This app uses push notifications feature, targeting the smartphone users, to help everyone study/learn.
- **Habit:** The app would be used on a daily basis. More specifically, user the user will have control over how frequently they want the app to provide them push notifications.
- **Scope:** V1 will let users post/edit custom notes and get push notification, in a periodic manner, about those notes and some math facts.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can register
* User can login/logout
* User can create new notes
* User can add photo to their notes using the camera
* User can view all of their notes in table view
* User can tap table view cell to view note details
* User can edit their notes
* User can turn on/off the notifications
* User can set interval of time and frequency of notifications they want like every 45 minutes from 9 am to 5 pm
* User can view random facts about numbers/math using [numbersapi](http://numbersapi.com/)

**Optional Nice-to-have Stories**

* Users can view other random facts like physics, chemistry, etc.
* Login with facebook
* Chat Functionality
* Group Functionality (depending upon subjects where user can post notes)
* Tapping on a push notification to directly go to that specific notes

### 2. Screen Archetypes

* Login/Register
   * User is able to create an account
   * User is able to login/logout from account
* Creation
   * User can add text and photos to notes that will be push notified
* Home
   * User can see all the notes they created
* Details
   * User can select a specific note and edit the note in detail view
* Settings
   * User can turn on/off the notification and edit notification timings

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Screen
* User Settings

**Flow Navigation** (Screen to Screen)

* Login/Registration Screen
* Home Screen (Collection view screen with Notes, Math Facts, etc.)
   * Settings
* Notes (Table View)
   * Detailed Screen
   * Creation Screen
   
## Wireframes

<img src="https://i.imgur.com/19GYDd5.jpg" width=600>

## Schema 
### Models
#### Post

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the user post (default field) |
   | author        | Pointer to User| post author |
   | image         | File     | image that user posts |
   | description   | String   | note/description for the image |
   | createdAt     | DateTime | date when post is created (default field) |
   | updatedAt     | DateTime | date when post is last updated (default field) |
   
#### Setting

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | notificationOn| Boolean  | is the notification turned on or off for the specific user|
   | from          | DateTime | time from which the user wants to be notified |
   | to            | DateTime | time to which the user wants to be notified |
   | interval      | Time/Number     | time interval for subsequent notifications (frequency)| 
   | createdAt     | DateTime | date when user setting is created (default field) |
   | updatedAt     | DateTime | date when user setting is last updated (default field) |
### Networking

- Notes Feed Screen
     - (Read/GET) Query all posts where user is author
         ```Objective-C
         PFQuery *postQuery = [Post query];
         [postQuery whereKey:@"author" isEqualTo:[PFUser currentUser]];
         [postQuery orderByDescending:@"createdAt"];
         ```
     - (Delete) Delete existing post

- Create Post Screen
     - (Create/POST) Create a new post object
         ```Objective-C
         Post *newPost = [Post new];
         newPost.image = [self getPFFileFromImage:image];
         newPost.author = [PFUser currentUser];
         newPost.description = description;
         [newPost saveInBackgroundWithBlock: completion];
         ```
- Note Details Screen
     - (Update/PUT) Update the note
     
- Setting Screen
     - (Read/GET) Query logged in user object's settings 
     - (Update/PUT) Update user settings


### Existing API Endpoints
##### An API of Numbers
- Base URL - [http://numbersapi.com](http://numbersapi.com/)

   HTTP Verb | Endpoint | Description
   ----------|----------|------------
    `GET`    | /random  | returns a fact about random number
    `GET`    | /random/year | returns a fact about random year
    `GET`    | /random/date   | returns a fact about random date
