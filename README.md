# Application Setup Guide

This guide provides instructions for setting up and running the application.

## Requirements
- **Ruby version:** 3.0.0
- **Rails version:** 7.0.8
- **Database:** SQLite3

## System Dependencies
Ensure the following gems are installed for the application:

- **Devise:** For authentication. [Devise GitHub](https://github.com/heartcombo/devise)
gem "devise", "~> 4.9"


- **Letter Opener:** For email notification in the development environment.
gem "letter_opener", group: :development


- **RSpec-Rails:** For testing.
gem 'rspec-rails'


- **Shoulda Matchers:** Additional testing utilities.
gem 'shoulda-matchers', '~> 5.3'


- **WebMock:** For mocking.
gem "webmock"


## Setup Instructions
1. **Install Dependencies:** Navigate to the application root directory and run:


2. **Database Setup:** 
- To set up the database, run:
  ```
  rake db:setup
  ```
- Then migrate the database schema with:
  ```
  bundle exec rails db:migrate
  ```

3. **Start Server:** Launch the server by running:


The application will be accessible at [http://127.0.0.1:3000](http://127.0.0.1:3000).

## Usage
- **Sign Up:** Visit the signup page by navigating to the root path. Provide an email, password (minimum 6 characters), and password confirmation to sign up.

- **Create Events:**
- Click on "Create Event A" to create an event.
- Click on "Create Event B" to create an event along with email notification.

- **Add Users to Event:** Navigate to any event by clicking on it. View event details and a list of associated users. To add more users, select them from the list and click on the "Add Users" button.

## Test Suite
To run the test suite, navigate to the application root directory and execute:

bundle exec rspec



