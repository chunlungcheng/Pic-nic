# Pic-nic
See what is going on in your city! Discover things to do or sights to see from others in your area, updated daily. Post a photo to your city’s feed, whether it be a good cup of coffee, a sunset, or a delicious meal. 
You can share, like, or comment on any photo you see to get more detail. Each photo is geotagged so you can see where it was taken. Think of Instagram but for only your city, and the feed is deleted at the end of each day. 

## Contributions  
Isaiah Suarez (33%)  
- Implemented upload function
- Photo is downsized, compressed, and uploaded to Firestore
- Created tasks for group members


Arjun Hegde (33%)  
- TBD

Chun-Lung Cheng (33%)  
- Setting Screen
    - Rebuilt the setting screen UI
    - View Controller
- Buttons
    - Cancel: return back to the Home screen
    - Save: save changes to the Firestore
    - Sign Out: sign out and segue to the Login screen
- User Information Text Fields (Firstname, Lastname, and Email 
    - placeholder is updated by the information retrieved from
Firestore in real-time
    - only first name and last name are editable
- ImageView (profile picture)
    - The profile picture retrieved from Firestore
    - Tapping on the picture can change the profile picture


John Park (0%)  
- Was supposed to implement the Home screen but has stopped responding
- Talked to Professor Bulko in OH

## Differences  
- Home screen not implemented due to group member going MIA
- The email placeholder currently holds the ‘user.uid’ because we don’t have email stored in Firestore yet. We will add it later.
