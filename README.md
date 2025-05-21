# MeetSpace

A modern meeting room booking system with a Flutter frontend and Node.js backend.

## Project Structure

```
MeetSpace/
├── frontend/              # Flutter frontend
│   ├── lib/               # Flutter source code
│   │   ├── models/        # Data models
│   │   ├── screens/       # App screens
│   │   ├── services/      # API services
│   │   ├── widgets/       # Reusable UI components
│   │   └── main.dart      # Main Flutter app
│   └── pubspec.yaml       # Flutter dependencies
└── backend/               # Node.js backend (separate repository)
    ├── controllers/       # API controllers
    ├── middleware/        # Express middleware
    ├── models/            # Data models
    ├── routes/            # API routes
    ├── config/            # Configuration files
    ├── server.js          # Main server file
    └── package.json       # Backend dependencies
```

## Features

- Modern, responsive UI for booking meeting rooms
- Interactive calendar for viewing and managing bookings
- Dashboard with booking analytics and insights
- Settings page for customizing user preferences
- Create, view, edit, and delete bookings
- Validation to prevent overlapping bookings
- Error handling and loading states
- Integration with MeetSpace backend API

## Backend API

The backend provides the following REST API endpoints:

### Rooms
- `GET /api/rooms` - Get all rooms
- `GET /api/rooms/:id` - Get a specific room
- `POST /api/rooms` - Create a new room
- `PUT /api/rooms/:id` - Update a room
- `DELETE /api/rooms/:id` - Delete a room

### Bookings
- `GET /api/bookings` - Get all bookings
- `GET /api/bookings/:id` - Get a specific booking
- `POST /api/bookings` - Create a new booking
- `PUT /api/bookings/:id` - Update a booking
- `DELETE /api/bookings/:id` - Delete a booking

## Setup Instructions

### Backend Setup

1. Clone the backend repository:
   ```
   git clone https://github.com/Dhanesh105/MeetSpace-backend.git
   cd MeetSpace-backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Create a `.env` file in the root directory with the following variables:
   ```
   PORT=4321
   MONGODB_URI=mongodb://localhost:27017/booking_app
   ```

4. Start the server:
   ```
   npm start
   ```

   The server will run on http://localhost:4321 by default.

### Frontend Setup

1. Clone the frontend repository:
   ```
   git clone https://github.com/Dhanesh105/MeetSpace.git
   cd MeetSpace
   ```

2. Make sure you have Flutter installed. If not, follow the [official installation guide](https://flutter.dev/docs/get-started/install).

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## API Usage Examples

### Create a Room

```
POST /api/rooms
Content-Type: application/json

{
  "name": "Conference Room A",
  "capacity": 10,
  "floor": 2,
  "amenities": ["Projector", "Whiteboard", "Video conferencing"],
  "isAvailable": true
}
```

### Create a Booking

```
POST /api/bookings
Content-Type: application/json

{
  "roomId": "60d21b4667d0d8992e610c85",
  "title": "Team Meeting",
  "description": "Weekly team sync-up",
  "startTime": "2025-03-01T10:00:00Z",
  "endTime": "2025-03-01T11:00:00Z",
  "attendees": ["john@example.com", "jane@example.com"],
  "createdBy": "john@example.com"
}
```

### Get All Bookings

```
GET /api/bookings
```

### Get Bookings for a Date Range

```
GET /api/bookings?startDate=2025-03-01T00:00:00Z&endDate=2025-03-02T00:00:00Z
```

### Get a Specific Booking

```
GET /api/bookings/:id
```

### Update a Booking

```
PUT /api/bookings/:id
Content-Type: application/json

{
  "title": "Updated Team Meeting",
  "description": "Weekly team sync-up with project updates",
  "startTime": "2025-03-01T10:30:00Z",
  "endTime": "2025-03-01T11:30:00Z"
}
```

### Delete a Booking

```
DELETE /api/bookings/:id
```

## Tech Stack

### Frontend
- Flutter for cross-platform UI development
- Dart programming language
- Provider for state management
- HTTP package for API communication
- Shared Preferences for local storage
- Table Calendar for calendar functionality

### Backend
- Node.js runtime environment
- Express.js web framework
- MongoDB for data storage
- Mongoose ODM for database interactions
- Swagger UI for API documentation

## Notes

- The frontend is configured to connect to the backend at http://localhost:4321. If your backend is running on a different URL, update the API endpoints in the service files.
- The backend uses MongoDB to store data, so make sure you have MongoDB running locally or update the connection string in the .env file.

## License

This project is licensed under the MIT License.
