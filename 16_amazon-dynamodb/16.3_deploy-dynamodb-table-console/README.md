# Deploy DynamoDB Table - Console Demonstration

## Overview
This 5-minute demonstration shows how to create and configure a DynamoDB table using the AWS Management Console. You'll learn to create a table, configure its settings, and perform basic operations through the web interface.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of NoSQL concepts

## Demonstration Steps (5 minutes)

### Step 1: Access DynamoDB Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to DynamoDB service:
   - Search for "DynamoDB" in the services search bar
   - Click on "DynamoDB" from the results
3. In the left navigation pane, click **Tables**

### Step 2: Create a New Table (2 minutes)
1. Click **Create table** button
2. Configure table details:
   - **Table name**: `ProductCatalog`
   - **Partition key**: `ProductId` (String)
   - **Sort key**: `Category` (String)
3. Keep **Table settings** as **Default settings** for this demo
4. Click **Create table**
5. Wait for table status to change to **ACTIVE** (usually 1-2 minutes)

### Step 3: Add Sample Data (1.5 minutes)
1. Once table is active, click on the table name to open it
2. Click **Explore table items**
3. Click **Create item**
4. Add the following attributes:
   - `ProductId`: `PROD001` (String)
   - `Category`: `Electronics` (String)
   - `ProductName`: `Wireless Headphones` (String)
   - `Price`: `99.99` (Number)
   - `InStock`: `true` (Boolean)
5. Click **Create item**
6. Repeat to add one more item:
   - `ProductId`: `PROD002` (String)
   - `Category`: `Books` (String)
   - `ProductName`: `AWS Architecture Guide` (String)
   - `Price`: `29.99` (Number)
   - `InStock`: `false` (Boolean)

### Step 4: Query and Scan Operations (1 minute)
1. In the **Explore table items** view:
   - Use **Scan** to view all items
   - Use **Query** to find specific items by partition key
   - Try querying for `ProductId = PROD001`
2. Show the different view options and filters available

## Key Learning Points
- DynamoDB tables require a partition key (and optionally a sort key)
- Tables are created with default settings for simplicity
- Items can have different attributes (schema-less design)
- Console provides easy-to-use interface for basic operations
- Query operations are more efficient than Scan operations

## Best Practices Demonstrated
- Use meaningful table and attribute names
- Partition keys should distribute data evenly
- Consider access patterns when designing keys
- Use appropriate data types for attributes

## Cleanup (Optional)
To avoid charges, delete the table after the demonstration:
1. Go back to **Tables** in the left navigation
2. Select the `ProductCatalog` table
3. Click **Delete**
4. Type the table name to confirm deletion
5. Click **Delete table**

## Additional Resources
- [Getting started with DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStartedDynamoDB.html)
- [Step 1: Create a table in DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html)
- [Working with items and attributes in DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithItems.html)

## Citations
1. AWS Documentation - Getting started with DynamoDB: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStartedDynamoDB.html
2. AWS Documentation - Create a table in DynamoDB: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html
3. AWS Documentation - Working with items and attributes: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithItems.html
