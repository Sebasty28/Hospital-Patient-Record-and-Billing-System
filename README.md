# Hospital Patient Record & Billing System

A comprehensive database management system for healthcare facilities, handling patient records, appointments, treatments, and automated billing operations.

---

## Developed by Group 2

- **Barnuevo, Arby**
- **Baylon, Darrel Andrew**
- **Belando, Sebastian Rafael**
- **Bering, Char Mae Grade**
- **Espinili, Ryel Jan**
- **Reyes, Rayver S.**

---

## Description

This system maintains patient records, appointments, treatments, and billing operations while ensuring secure access control and reliable data backups. Built with database best practices including normalization, triggers, and stored procedures.

---

## Objectives

- Integrate multiple tables with well-defined relationships
- Use triggers and stored procedures to automate billing processes
- Implement comprehensive database backup and restore functionality

---

## Major Features

- **Core Tables**: Patients, Doctors, Appointments, Treatments, Billing
- **Automation**: Stored procedures for billing calculations
- **Audit System**: Triggers for tracking billing modifications
- **Analytics**: Subqueries for unpaid balances and revenue reports
- **Data Management**: Import/export capabilities for billing data
- **Security**: Role-based access control (Admin, Doctor, Clerk)

---

## Deliverables

1.  ERD & Schema Design (normalized)
2.  SQL Scripts for Table Creation & Sample Data
3.  CRUD Operations for patient registration and doctor assignment
4.  SQL Queries:
   - Daily patient list per doctor
   - Revenue analysis by department (GROUP BY)
5.  Stored Procedure: Auto-generate billing totals
6.  Trigger: Audit trail for billing updates/deletes
7.  View: Monthly revenue summary
8.  Import/Export: CSV billing reports
9.  Backup/Restore simulation
10.  Security roles and access control demo
11.  Full documentation & presentation

---

## Documentation

[View Full Documentation & SQL Scripts on Notion](https://www.notion.so/Hospital-Patient-Record-Billing-System-2e1716df3693803eb93dda84a4e57eae?source=copy_link)

---

## Getting Started

### Prerequisites
- MySQL Server 8.0 or higher
- PhpMyAdmin

### Installation
1. Clone this repository
2. Open the SQL script in phpMyAdmin
3. Execute the script to create the database structure
4. Load sample data (included in script)

---


## Security & Access Control

The system implements three security roles:
- **Admin**: Full database access
- **Doctor**: Patient records and appointments
- **Clerk**: Billing and administrative functions

---

##  Contact

For questions or collaboration, please reach out to any team member listed above.

---

## License

This project is part of an academic requirement.
