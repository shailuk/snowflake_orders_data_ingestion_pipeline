# Automated Data Ingestion Pipeline with Snowflake Snowpipe and AWS S3

An end-to-end, event based data ingestion pipeline that automatically loads CSV data from an Amazon S3 bucket into Snowflake using **Snowpipe (Auto-Ingest)**. 

This project also demonstrates secure cross-account authentication using AWS IAM Trust Relationships and event-driven orchestration via AWS SQS notifications.

---

## 🏗️ Architecture Overview

The pipeline implements a highly secure, decoupled, and event-driven handshake between a personal AWS infrastructure account and Snowflake’s managed SaaS environment:

1. **File Landing:** A CSV data file is uploaded into a designated Amazon S3 bucket path.
2. **Event Trigger:** S3 detects the object creation event and publishes a notification to a Snowflake-managed **Amazon SQS** queue.
3. **Secure Access:** Snowpipe wakes up upon receiving the SQS message and assumes a custom **AWS IAM Role** using a secure Cross-Account Trust Relationship (validating the specific Snowflake IAM User and External ID).
4. **Ingestion:** Snowpipe safely reads the raw data from S3, maps it through a custom File Format, and executes a continuous `COPY INTO` command to load the structured data into a landing-zone table (`orders_data_lz`).

---

## 🛠️ Tech Stack & Environment
* **Data Warehouse:** Snowflake
* **Cloud Provider:** Amazon Web Services (AWS)
* **Storage Services:** AWS S3, AWS SQS
* **Security & Governance:** AWS IAM (Cross-Account Role & Trust Policies)
* **Language:** Snowflake SQL

---
