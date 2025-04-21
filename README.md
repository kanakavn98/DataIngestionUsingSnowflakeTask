# DataIngestionUsingSnowflakeTask
This project demonstrates a scalable data ingestion pipeline that integrates AWS S3 with Snowflake to enable seamless and efficient loading of structured data. The workflow involves uploading raw data to an S3 bucket and automating its ingestion into Snowflake tables using stages, file formats, and COPY INTO commands.

🔍 Key Features:
- Configured external stages in Snowflake linked to AWS S3
- Applied file format definitions for flexible data parsing (CSV, JSON, etc.)
- Used COPY INTO commands to load data into Snowflake tables
- Managed permissions and security integration between Snowflake and AWS IAM
- Includes sample scripts and SQL queries for reproducibility

🚀 Technologies Used:
- Snowflake (Data Warehouse)
- AWS S3 (Cloud Storage)
- SQL (Data Definition & Manipulation)
- Python (optional for automation with snowflake-connector)
