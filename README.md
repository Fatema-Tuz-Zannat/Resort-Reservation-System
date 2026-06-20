# Resort Reservation System

## Overview

The Resort Reservation System is a Bash Shell Script-based application designed to manage room reservations and theater service bookings for a private family resort. The system provides an easy-to-use command-line interface that allows customers to reserve rooms, check availability, cancel reservations, and book theater services while maintaining customer records and VIP benefits.

## Features

* Room reservation management
* Vacancy checking for upcoming dates
* Reservation cancellation
* Theater service booking
* Theater slot availability monitoring
* VIP customer discount system
* Automatic booking conflict resolution
* Data storage using text files

## Technologies Used

* Bash Shell Scripting
* Linux Command-Line Utilities
* AWK
* Sort
* Date Functions
* Text File Management

## System Functionality

### Room Reservation

Users can:

* Enter personal information (Name and NID)
* Select room quantity
* Choose check-in and check-out dates
* View reservation receipts
* Receive VIP discounts based on previous stays

### Vacancy Management

The system checks room availability before confirming a reservation to prevent overbooking.

### Reservation Cancellation

Customers can cancel their reservations using their NID number.

### Theater Service Booking

Guests can reserve theater slots:

* Evening Slot (3:00 PM – 7:00 PM)
* Night Slot (8:00 PM – 12:00 AM)

### VIP Discount Policy

| Visit Number        | Discount |
| ------------------- | -------- |
| 1st Visit           | 0%       |
| 2nd Visit           | 5%       |
| 3rd Visit           | 10%      |
| 4th Visit           | 20%      |
| 5th Visit and Above | 30%      |

## Project Structure

```text
Resort Reservation System.sh
ledger.txt          # Reservation records
theater.txt         # Theater booking records
```

## How to Run

1. Open a Linux terminal.
2. Give execute permission:

```bash
chmod +x "Resort Reservation System.sh"
```

3. Run the script:

```bash
./"Resort Reservation System.sh"
```

## Learning Outcomes

This project demonstrates:

* Shell scripting concepts
* File handling and data storage
* Function implementation
* Conditional statements and loops
* Data processing using AWK
* Sorting and searching records
* Real-world reservation system design

## Future Improvements

* Graphical User Interface (GUI)
* Database integration
* Online payment system
* Email/SMS notifications
* Multi-user access control
* Enhanced reporting features

