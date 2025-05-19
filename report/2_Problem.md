
# 2.1 - Problem definition

Based on the described functionality and the market need , to address the problem and before implementing the solution we need to perform definition of out needs followed by modeling of the problem and the solution addressing it and for that we rely on **UML** (**U**nified **M**odeling **L**anguage) starting by defining the general then the specific functionalities of the platform :
# 2.2 - General
+ The app is administrated by global admin and mods
+ mods can review reports, take user-based actions and create communities
+ users can join communities and post threads
+ users must be signed-in in order to perform user actions
+ users can send DM (Direct Messages) to other users once they have their ID
+ Each community has Mods, Rules and owner
+ Each user has ranking that is auto-evaluated based on other users votes on his posts and comments
+ Each user has privacy settings that controls who can search, message and interact with him or his content (more robust to avoid scams and distraction)
+ Each user can view the public listing of the course
+ No signup is required for user to view the courses listings
+ Each entry of the listing is validated and entered by a company team after making contracts with private schools and checking their validity
+ User can search and view details of each course to find the best fit for his needs
# 2.3 - Context

Universal platform that integrates two distinct services : Forum communication service and Courses listing service
# 2.4 - Domain

+ The app satisfies the two addressed needs : Distraction-free learners communication service and in-person reviewed courses listings service
+ The app main income comes from private schools who pays to get their courses reviewed and listed and later offer premium educational services switching to freemium model for learners
+ The app is **not** a social media platform
+ The app is **not** a classical CMS (Content Management System)
+ The app does **not** target general users
+ The app main customers are : private school and learners mainly students
# 2.5 - Objectives

+ Be distraction free and learning-friendly : Forum community style with privacy settings
+ Be easy to use
+ Provide robust content evaluation system : upvotes/downvotes
+ Be Community driven : threads and comments
+ Provide quality recommendations : courses review before listings
# 2.6 - Requirements analysis
## 2.6.1 - Functional Requirements

+ Communities : admin created, official only that represents a population within the forum and has a main topic that is discussed within it, eg : programming, Computer-Science ... Community creation can be requested and will be enabled to regular users at later phase, each community has an owner who chooses moderators and can pass it later to another user to maintain it
+ Moderator : one level below admin , its role is to moderate regular users within a community and has actions on them such as : ban, warn, delete ... their role is to monitor the integrity of the community and review reports and requests
+ Post : a thread created within a community which users can comment on and evaluate using votes, each thread represent an open discussion that can be : resource sharing, question, information sharing or a debate
+ Comment : a reply on a thread that can be created by regular user to express their opinions on a topic, each comment can be replied on and is subject to votes
+ Upvote : an evaluation mechanism that can be performed by a user of which a post or comment is ranked 1 point higher
+ Downvote : an evaluation mechanism that can be performed by a user of which a post or comment is ranked 1 point lower
+ Ban : a moderator/admin action that can be performed on any user who violates the terms of the service, of which an account can no longer be active on the platform
+ Warning : a moderator/admin action that can be performed on any user who violates the terms of the service, of which an account can receive a warning along description of the violating action, multiple warnings makes the user subject to auto-ban
+ Course-Listing : an entry within the listing service representing a course and its corresponding info
## 2.6.2 - Non Functional Requirements

+ Reliability of the service : The services must be always running including maintenance time , following zero-downtime strategy by separating development, testing and deployment services
+ Database Distribution : Since being local-first and following the privacy laws including Law N 18-07 which implies the physical and logical protection of Algerian citizens data , the app will start with centralized database and aims for distributed instances as it scales to provide faster access
+ Ease of use : following UI/UX best practices, the app provides easy to use web interface without requiring constant page reloading by using SPA design for the interface
+ Security of the services : using best security practices, update software and periodic pentesting

<div style="page-break-before: always; height: 0;"></div>