Carpool App Overview
The Carpool app is a cross-platform solution designed to reduce carbon footprints by facilitating carpooling for individuals traveling along the same route. Currently in its MVP stage, the app allows riders to request rides from drivers traveling between matching origin and destination locations. The long-term vision includes addressing challenges such as:

Enhancing security by verifying government IDs of drivers and riders.
Providing convenient pickup options by implementing a 0.5-mile walking distance policy.
Offering free electric bikes to minimize walking distances for riders.
The app features two distinct interfaces for Drivers and Riders:

Drivers can start or cancel rides and handle incoming ride requests in real-time, choosing to accept or reject them.
Riders can search for available rides and wait for their requests to be accepted or rejected.


PROTOTYPE
<img width="929" alt="prototype" src="https://github.com/user-attachments/assets/e257ab20-2869-40f2-b56b-9541308934f1" />


FLOWCHART
<img width="789" alt="flowchart" src="https://github.com/user-attachments/assets/6e63f685-022e-4723-8432-a63a1dd43fe0" />


Technical Deep Dive
1. User Authentication & Firestore
User authentication is implemented via Firebase Authentication, supporting sign-up/sign-in using email-password or Google account login.

On the launch screen, users can select their role (Driver or Rider) for registration or login.
Each user’s details are stored in the users collection in Firebase Firestore, ensuring that a single user cannot register as both a driver and a rider. If this condition is violated, the system displays an error.

2. Firestore & Google Maps Platform Integration
Firestore Usage:

Stores user details, driver availability, incoming ride requests, and related data.
When a driver starts a ride, the isDriving property is set to true, making them visible to riders for ride requests.
Ride requests are stored as objects in the requests collections for both drivers and riders, containing details like rider name, lat/lng points, and status.
This enables real-time tracking and updates for both parties.
Google Maps Platform:

Places API and Directions API are used to fetch and render route polylines on the Google Map Widget for both drivers and riders.
Note: While the current design leverages Firestore's real-time event capabilities for updates, this approach may not scale efficiently. For larger-scale deployments, an event-driven architecture would be required.

 Driver and Rider Matching Process
Drivers and riders are matched based on latitude and longitude coordinates of their start and end locations.

Technologies Used
Frontend: Flutter SDK
Backend: Firebase Authentication, Firestore
Mapping Services: Google Maps Platform APIs (Places & Directions API)
