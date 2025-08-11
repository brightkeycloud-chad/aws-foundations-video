# Amazon SageMaker Canvas AI-Powered Data Analysis Demo

## Overview
This 5-minute demonstration showcases the modern Amazon SageMaker Canvas experience, now fully integrated with SageMaker AI Studio. You'll explore Canvas's no-code machine learning capabilities, including generative AI features, ready-to-use models, and custom model building - all within the unified SageMaker AI ecosystem.

## Prerequisites
- AWS Account with appropriate permissions
- SageMaker AI domain with Canvas permissions enabled
- Basic understanding of business analytics and machine learning concepts

## Demo Steps (5 minutes)

### Step 1: Access Modern SageMaker Canvas via Studio (1 minute)

1. **Navigate to SageMaker AI Console**
   - Open AWS Console and search for "SageMaker"
   - Click on "Amazon SageMaker" service
   - Ensure you're using the modern SageMaker AI interface

2. **Access Canvas through Studio**
   - Click "Domains" in the left navigation
   - If no domain exists, create one with "Quick setup" 
     - Quick setup automatically enables Canvas permissions
     - Creates domain name like `QuickSetupDomain-YYYYMMDDTHHMMSS`
   - Click on your domain name (will be auto-generated)
   - Click "Launch" next to your user profile
   - In the Studio interface, look for "Canvas" in the applications section
   - Click "Canvas" to launch the application

3. **Canvas Modern Interface**
   - Canvas now opens as an integrated application within Studio
   - Notice the unified navigation with other SageMaker AI tools

### Step 2: Explore Canvas AI Capabilities (1.5 minutes)

1. **Canvas Chat with Foundation Models**
   - Click on "Chat" in the Canvas interface
   - Demonstrate the generative AI capabilities:
     ```
     Prompt: "Explain customer churn analysis in simple business terms"
     ```
   - Show how Canvas leverages LLMs for business insights

2. **Ready-to-Use Models**
   - Navigate to "Ready-to-use models"
   - Highlight available AI services integration:
     - Text analysis (Amazon Comprehend)
     - Image recognition (Amazon Rekognition)
     - Document analysis (Amazon Textract)
   - These require no model training - just data input

### Step 3: Build Custom Predictive Model (2 minutes)

1. **Import Sample Data**
   - Click "Datasets" in Canvas
   - Choose "Upload from computer"
   - Upload the provided `sample-customer-data.csv`
   - Canvas automatically analyzes data quality and suggests improvements

2. **Create Predictive Model**
   - Click "Models" → "Create model"
   - Choose "Predictive analysis"
   - Name: `modern-churn-prediction`
   - Select the uploaded dataset
   - Choose target column: `churn`

3. **Enhanced Model Building**
   - Canvas now offers:
     - **Quick build**: 2-4 minutes (for demo)
     - **Standard build**: More comprehensive analysis
     - **Advanced options**: Custom feature engineering
   - Select "Quick build" for the demonstration

4. **AI-Powered Insights**
   - While model builds, Canvas provides:
     - Automated data quality assessment
     - Feature importance predictions
     - Business impact estimates

### Step 4: Analyze Results and Generate Insights (0.5 minutes)

1. **Model Performance Dashboard**
   - View enhanced metrics with business context
   - Canvas explains model performance in business terms
   - Feature importance with actionable insights

2. **AI-Generated Recommendations**
   - Canvas now provides AI-powered business recommendations
   - Explains which factors most influence customer churn
   - Suggests actionable business strategies

3. **Prediction Interface**
   - Use the enhanced prediction interface
   - Generate predictions with confidence intervals
   - Export results with business-friendly explanations

## Key Modern Canvas Features to Highlight

- **Generative AI Integration**: Chat with LLMs for business insights
- **Studio Integration**: Seamless workflow with other SageMaker AI tools
- **Enhanced AutoML**: More sophisticated automated machine learning
- **Business Context**: AI explanations in business-friendly language
- **Ready-to-Use Models**: Immediate access to AWS AI services
- **Improved Data Preparation**: AI-assisted data quality improvements
- **Advanced Visualizations**: Better charts and business dashboards

## Modern Canvas Capabilities

### Generative AI Features
- **Canvas Chat**: Interact with foundation models for insights
- **Document Querying**: Ask questions about your business documents
- **Content Generation**: Create business reports and summaries

### Enhanced Analytics
- **Automated Feature Engineering**: AI-powered data preparation
- **Business Impact Modeling**: Understand ROI of predictions
- **Advanced Time Series**: Improved forecasting capabilities
- **Multi-Modal Analysis**: Text, image, and tabular data combined

### Integration Benefits
- **Unified Workspace**: All ML tools in one interface
- **Shared Resources**: Models and data accessible across Studio
- **Collaborative Features**: Share insights with technical teams
- **Enterprise Security**: Enhanced governance and compliance

## Business Use Cases (2024 Focus)

- **AI-Powered Customer Analytics**: Combine traditional ML with generative AI
- **Intelligent Document Processing**: Extract insights from business documents
- **Conversational Business Intelligence**: Ask questions about your data
- **Automated Report Generation**: AI-created business summaries
- **Multi-Modal Insights**: Analyze text, images, and data together

## Troubleshooting

- Ensure Canvas permissions are enabled in your SageMaker AI domain
- Verify you're using the modern Studio experience (not Studio Classic)
- Check that generative AI features are enabled for your region
- For document querying, ensure proper IAM permissions for foundation models

## Cost Considerations (2024 Pricing)

- **Canvas Sessions**: Charged per session hour
- **Model Building**: Quick build (~$0.25-1.00), Standard build (~$2-10)
- **Generative AI**: Token-based pricing for chat features
- **Ready-to-Use Models**: Pay-per-use for AWS AI services
- **Predictions**: Per-prediction pricing

## Next Steps

After this demo, participants can:
- Explore advanced generative AI features in Canvas
- Connect to enterprise data sources (Redshift, Snowflake, etc.)
- Use Canvas with Amazon Q Developer for enhanced ML assistance
- Deploy models for real-time business applications
- Integrate Canvas insights with business intelligence tools
- Explore multi-modal analysis capabilities

## Citations and Documentation

1. [Amazon SageMaker Canvas (Modern Experience)](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas.html)
2. [Getting Started with SageMaker Canvas](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-getting-started.html)
3. [Generative AI Foundation Models in Canvas](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-fm-chat.html)
4. [Canvas Ready-to-Use Models](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-ready-to-use-models.html)
5. [Canvas Custom Models](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-custom-models.html)
6. [Canvas Setup and Permissions](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-setting-up.html)
7. [SageMaker Canvas Pricing](https://aws.amazon.com/sagemaker/canvas/pricing/)
