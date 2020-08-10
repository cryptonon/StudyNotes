# *StudyNotes*

## Table of Contents
1. [Overview](#Overview)
2. [User Stories](#User-Stories)
3. [Video Walkthrough](#Video-Walkthrough)
4. [Credits](#Credits)
5. [License](#License)

## Overview

**StudyNotes** is an app that lets users post their personal study notes and share study notes in different groups. This app also sends notifications about the user's personal notes in a certain interval of time that can be set by users (like every 2 hours from 9 am to 5 pm, from 08/09/2020 to 08/11/2020)

A note consists of a note image, title, and description. The notifications will have the details about a specific note; the notification title will be a note's title and notification body will contain the note's description.

**Platform**: iOS
**Category**: Education/Productivity


## User Stories

#### 1. User Authentication

- [X] User can login/signup/continue with Facebook
- [X] The current signed in user is persisted across app restarts
- [X] Signed in user can logout

#### 2. Creating/Editing/Deleting Notes

- [X] User can create a new note/edit existing note using camera or library images
- [X] User can crop the images to desized sizes
- [X] User can edit note image, title and description
- [X] User can delete the created notes by swiping (trailing) table view cell 

#### 3. Viewing all saved notes

- [X] User can view all their notes with note image, title, and description preview in a table view.
- [X] User can view the detailed view of the note and can edit the note from details screen

#### 4. Deleting a note
- [X] User can delete their personal notes
- [X] User can swipe table view cellss from right to left and use delete button to delete the note

#### 5. Viewing random numbers fact

- [X] User can view a random number fact fetched from [numbersapi](http://numbersapi.com/#42)
- [X] User can generate new random fact by reloading

#### 6. Updating Notification Settings

- [X] User can opt in for local push notifications
- [X] User can specify the timeframe for notifications (like from July 28 to August 1, 9:00 am to 5:00 pm, every 2 hours)
- [X] Notifications will have title of a specific note title and notification body will contain that note’s description
- [X] Notifications will only contain user's personal notes
- [X] User will only get notification for the same note again only when a cycle has been completed
- [X] User cannot schedule notifications if they have no saved notes

#### 7. Creating a Group

- [X] A group will have a name and description
- [X] User can create a new group for sharing notes to other users
- [X] For now, the groups are public i.e. everyone will have access to every groups created (both viewing and posting notes in the group)

#### 8. Creating/Editing Notes on the groups

- [X] Users can publicly post notes to specific groups similarly to creating personal notes
- [X] Specific users can only edit the notes i.e. only if they have created that specific note

#### 9. Viewing all Groups and posted Notes

- [X] User can view all groups with their names and respective descriptions in groups tab
- [X] User can view notes posted in all groups in a table view like user can view their presonal notes
- [X] User can also view the detailed view of all notes in details screen in similar way to presonal notes 

#### 10. Editing/Deleting Groups

- [X] Group Details (Name/Description) can be edited by the owner/creator of the group only
- [X] Groups can be deleted by the owner/creator of the group only

#### 11. Scheduled notifications cancel on Logout and Resume on subsequent Login

- [X] Scheduled Notifications are cancelled upon Logout
- [X] Users are asked if they want to resume previously Scheduled Notifications upon subsequent Login after Logout
- [X] Notifications resume upon Login if Users allow Permission to resume


## Video Walkthrough

#### [*Video Demo*](https://drive.google.com/file/d/1sl6kwpny2AOBOtm9ppwkVu8VEgzO9Alu/view?usp=sharing)

#### GIFs
1. <img src='http://g.recordit.co/5vXFe3LUZk.gif' title='Video Walkthrough' width='' alt='' />
2. <img src='http://g.recordit.co/vfIBDVtAfC.gif' title='Video Walkthrough' width='' alt='' />
3. <img src='http://g.recordit.co/XwY0zdhMLe.gif' title='Video Walkthrough' width='' alt='' />
4. <img src='http://g.recordit.co/AQDjYBdLKn.gif' title='Video Walkthrough' width='' alt='' />
5. <img src='http://g.recordit.co/VeavuCcUPp.gif' title='Video Walkthrough' width='' alt='' />
6. <img src='http://g.recordit.co/WziNZr1gdO.gif' title='Video Walkthrough' width='' alt='' />
7. <img src='http://g.recordit.co/LnVZ7HHQs7.gif' title='Video Walkthrough' width='' alt='' />
8. <img src='http://g.recordit.co/LYbrme5yEp.gif' title='Video Walkthrough' width='' alt='' />
9. <img src='http://g.recordit.co/1rIqJpSEAV.gif' title='Video Walkthrough' width='' alt='' />

GIF created with [Recordit.co](https://recordit.co/).

## Credits

3rd party libraries, icons, graphics, or other assets used in the app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) 
- [App Icon](https://drive.google.com/open?id=1UQyC-HpWPfauYWJ4loRQsg1nSmLCMVlg)
- [App Theme Image](https://upload.wikimedia.org/wikipedia/en/thumb/4/49/Carter-notes-pope-mtg-xl.jpg/1920px-Carter-notes-pope-mtg-xl.jpg)
- [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)
- [Numbers API](http://numbersapi.com/)
- [Parse](https://github.com/parse-community/Parse-SDK-iOS-OSX)
- [PopOverMenu](https://github.com/tichise/PopOverMenu)
- [SCLAlertView-Objective-C](https://github.com/dogo/SCLAlertView)
- [TOCropViewController](https://github.com/TimOliver/TOCropViewController)


## License

```
MIT License

Copyright (c) 2020 Aayush Phuyal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
