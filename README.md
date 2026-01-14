# ArtXchange - Art Marketplace Platform

A comprehensive web-based art marketplace platform built with Java, JSP, Firebase, and Maven. This platform allows artists to showcase and sell their artwork, while buyers can browse, purchase, and interact with artists through an integrated messaging system.

## 🎨 Features

- **User Authentication**: Firebase-based authentication system
- **Artwork Management**: Upload, edit, and manage artwork listings
- **Auction System**: Real-time bidding on artwork
- **Messaging System**: Direct communication between artists and buyers
- **Search & Filter**: Advanced artwork discovery with filters
- **Admin Dashboard**: Administrative tools for platform management
- **Responsive Design**: Mobile-friendly user interface

## 🛠 Prerequisites

Before running this project in NetBeans, ensure you have the following installed:

### Required Software
- **Java Development Kit (JDK) 11 or higher**
- **Apache NetBeans IDE 12.0 or higher**
- **Apache Maven 3.6.0 or higher**
- **Apache Tomcat 10.x**

### Firebase Setup
- Firebase project with Firestore database
- Firebase Authentication enabled
- Firebase service account key file

## 📁 Project Structure

```
artexchange/
├── src/main/java/com/artexchange/    # Java source files
│   ├── config/                       # Configuration classes
│   ├── dao/                          # Data Access Objects
│   ├── model/                        # Entity classes
│   ├── servlet/                      # Servlet controllers
│   └── util/                         # Utility classes
├── src/main/webapp/                  # Web application files
│   ├── *.jsp                         # JSP pages
│   ├── assets/                       # CSS, JS, images
│   └── WEB-INF/                      # Web configuration
├── src/main/resources/               # Resources
│   └── firebase-service-account.json # Firebase credentials
├── pom.xml                          # Maven configuration
└── run-dev.sh                       # Development script
```

## 🚀 Setup Instructions for NetBeans

### 1. Clone/Open Project in NetBeans

1. **Open NetBeans IDE**
2. **Open Project**:
   - Go to `File` → `Open Project`
   - Navigate to `/Volumes/SSD 980 PRO/artexchange`
   - Select the project folder and click `Open Project`
3. **NetBeans will automatically detect it as a Maven project**

### 2. Configure Maven Dependencies

1. **Right-click on the project** in the Projects panel
2. **Select "Build with Dependencies"** or press `Shift + F11`
3. **Wait for Maven to download all dependencies** (this may take a few minutes)

### 3. Firebase Configuration

1. **Obtain Firebase Service Account Key**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings → Service Accounts
   - Generate a new private key
   - Download the JSON file

2. **Add Firebase Credentials**:
   - Place the downloaded JSON file in `src/main/resources/`
   - Rename it to `firebase-service-account.json`

3. **Update Firebase Configuration**:
   - Open `src/main/webapp/assets/js/firebase-config.js`
   - Update the Firebase configuration with your project details:
   ```javascript
   const firebaseConfig = {
     apiKey: "your-api-key",
     authDomain: "your-project.firebaseapp.com",
     projectId: "your-project-id",
     // ... other config values
   };
   ```

### 4. Configure Tomcat Server in NetBeans

1. **Add Tomcat Server**:
   - Go to `Tools` → `Servers`
   - Click `Add Server`
   - Choose `Apache Tomcat or TomEE`
   - Browse to your Tomcat installation directory
   - Set Server Name (e.g., "Tomcat 10")
   - Click `Finish`

2. **Configure Project to Use Tomcat**:
   - Right-click on the project
   - Select `Properties`
   - Go to `Run` category
   - Set `Server` to your configured Tomcat server
   - Set `Context Path` to `/artexchange`

### 5. Build and Deploy

#### Method 1: Using NetBeans IDE

1. **Clean and Build**:
   - Right-click on project → `Clean and Build`
   - Or press `Shift + F11`

2. **Run Project**:
   - Right-click on project → `Run`
   - Or press `F6`
   - NetBeans will automatically deploy to Tomcat and open the application

#### Method 2: Using Terminal/Command Line

1. **Open Terminal in NetBeans**:
   - Go to `Window` → `IDE Tools` → `Terminal`
   - Navigate to project directory

2. **Run Development Script**:
   ```bash
   chmod +x run-dev.sh
   ./run-dev.sh
   ```

3. **Or use Maven directly**:
   ```bash
   mvn clean package
   mvn cargo:run
   ```

## 🌐 Accessing the Application

Once the server starts successfully, access the application at:
- **Main Application**: http://localhost:8080/artexchange/
- **Browse Artworks**: http://localhost:8080/artexchange/browse.jsp
- **Admin Dashboard**: http://localhost:8080/artexchange/admin/dashboard.jsp

## 📝 Development Workflow

### Making Changes

1. **Edit Source Files**: Modify Java, JSP, CSS, or JS files
2. **Hot Reload**: 
   - For JSP/CSS/JS changes: Simply refresh the browser
   - For Java changes: Use NetBeans' "Deploy on Save" feature or rebuild

### Debugging

1. **Enable Debug Mode**:
   - Right-click project → `Debug`
   - Or press `Ctrl + F5`

2. **Set Breakpoints**:
   - Click on line numbers in Java files to set breakpoints
   - Use the debugger to step through code

### Project Structure in NetBeans

```
📁 ArtXchange Project
├── 📁 Source Packages
│   └── 📁 com.artexchange
│       ├── 📁 config          # Firebase & app configuration
│       ├── 📁 dao             # Database access layer
│       ├── 📁 model           # Data models
│       ├── 📁 servlet         # Web controllers
│       └── 📁 util            # Helper utilities
├── 📁 Web Pages
│   ├── 📄 *.jsp               # JSP view pages
│   ├── 📁 assets              # Static resources
│   └── 📁 WEB-INF            # Web configuration
├── 📁 Dependencies           # Maven dependencies
└── 📁 Project Files          # Maven POM, configs
```

## 🔧 Troubleshooting

### Common Issues

1. **Port 8080 Already in Use**:
   ```bash
   # Kill processes using port 8080
   lsof -ti:8080 | xargs kill -9
   ```

2. **Firebase Connection Issues**:
   - Verify `firebase-service-account.json` is in the correct location
   - Check Firebase project permissions
   - Ensure Firestore is enabled in Firebase Console

3. **Maven Dependencies Not Downloading**:
   - Check internet connection
   - Clear Maven cache: `rm -rf ~/.m2/repository`
   - Refresh dependencies in NetBeans

4. **Tomcat Deployment Issues**:
   - Check Tomcat logs in NetBeans Output window
   - Verify Tomcat server configuration
   - Ensure no other applications are using the same context path

### Log Files

- **NetBeans Output**: Check the Output window for build and deployment logs
- **Tomcat Logs**: Available in NetBeans Services → Servers → Tomcat → View Server Log
- **Application Logs**: Console output will show in NetBeans Output window

## 📚 Key Pages and Features

### User Pages
- **Homepage** (`index.jsp`): Landing page with featured artworks
- **Browse** (`browse.jsp`): Search and filter artworks
- **Auctions** (`auctions.jsp`): Live auction listings
- **Messages** (`messages.jsp`): Artist-buyer communication
- **Profile** (`profile.jsp`): User profile management

### Admin Pages
- **Admin Dashboard** (`admin/dashboard.jsp`): Platform administration

### Key Features to Test
1. **User Registration/Login**: Firebase authentication
2. **Artwork Upload**: Image upload and metadata
3. **Contact Artist**: Messaging system integration
4. **Search/Filter**: Advanced artwork discovery
5. **Auction Bidding**: Real-time bid placement

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For issues or questions:
- Check the troubleshooting section above
- Review NetBeans Output and server logs
- Ensure all prerequisites are properly installed

---

**Happy Coding! 🎨**
