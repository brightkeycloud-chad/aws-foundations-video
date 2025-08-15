# Implement AWS Organizations Tag Policies Demo

## Overview
This 5-minute demonstration shows how to create and implement tag policies in AWS Organizations to standardize tagging across multiple AWS accounts, ensuring consistent cost allocation and governance.

## Prerequisites
- AWS Organizations with all features enabled
- Management account access with Organizations permissions
- At least one member account in the organization
- Understanding of JSON policy syntax (basic level)

## Demonstration Steps (5 minutes)

### Step 1: Access AWS Organizations Console (30 seconds)
1. Sign in to the AWS Management Console as the management account
2. Navigate to **AWS Organizations**
3. In the left navigation pane, click **Policies**
4. Click on **Tag policies** tab
5. Verify that tag policies are enabled (if not, click **Enable tag policies**)

### Step 2: Create a Tag Policy (2 minutes)
1. Click **Create policy**
2. **Policy name**: Enter `StandardCostAllocationTags`
3. **Description**: Enter `Enforces standard cost allocation tags across all accounts`

4. **Create the policy JSON**:
```json
{
  "tags": {
    "Environment": {
      "tag_key": {
        "@@assign": "Environment"
      },
      "tag_value": {
        "@@assign": [
          "Production",
          "Development", 
          "Staging",
          "Testing"
        ]
      },
      "enforced_for": {
        "@@assign": [
          "ec2:instance",
          "s3:bucket",
          "rds:db"
        ]
      }
    },
    "CostCenter": {
      "tag_key": {
        "@@assign": "CostCenter"
      },
      "tag_value": {
        "@@assign": [
          "Engineering",
          "Marketing",
          "Finance",
          "Operations"
        ]
      },
      "enforced_for": {
        "@@assign": [
          "ec2:instance",
          "s3:bucket"
        ]
      }
    },
    "Project": {
      "tag_key": {
        "@@assign": "Project"
      },
      "enforced_for": {
        "@@assign": [
          "ec2:instance"
        ]
      }
    }
  }
}
```

5. Click **Create policy**

### Step 3: Attach Policy to Organizational Unit (1 minute)
1. In the left navigation, click **AWS accounts**
2. Click on **Root** or select a specific Organizational Unit (OU)
3. In the **Policies** tab, click **Attach**
4. Select **Tag policies**
5. Check the box next to `StandardCostAllocationTags`
6. Click **Attach policy**
7. Verify the policy is now listed under attached policies

### Step 4: Test Policy Compliance (1 minute)
1. Navigate to **Resource Groups & Tag Editor**
2. Click **Tag Editor**
3. **Regions**: Select your working region
4. **Resource types**: Select `EC2 Instance`
5. Click **Search resources**
6. Select an EC2 instance from the results
7. Click **Manage tags of selected resources**
8. Attempt to add a tag that violates the policy:
   - Key: `Environment`
   - Value: `InvalidValue` (not in allowed list)
9. Demonstrate that the policy prevents non-compliant tagging

### Step 5: Monitor Compliance (30 seconds)
1. Return to **Resource Groups & Tag Editor**
2. Click **Tag policies** in the left navigation
3. Select your policy `StandardCostAllocationTags`
4. Click **Resources** tab to view compliance status
5. Show compliant and non-compliant resources
6. Explain how to use this for ongoing governance

## Policy Components Explained

### Tag Policy Structure
- **`tag_key`**: Defines the required tag key name
- **`tag_value`**: Specifies allowed values (optional)
- **`enforced_for`**: Lists resource types where the policy is enforced
- **`@@assign`**: Operator that sets the allowed values

### Enforcement Levels
- **Preventive**: Blocks non-compliant tagging operations
- **Detective**: Identifies non-compliant resources for remediation
- **Inheritance**: Child OUs inherit parent policies

### Resource Type Format
- Format: `service:resource-type`
- Examples: `ec2:instance`, `s3:bucket`, `rds:db-instance`
- Use `*:*` for all resource types (not recommended for enforcement)

## Key Benefits Demonstrated
- **Standardization**: Consistent tagging across all accounts
- **Cost Governance**: Ensures proper cost allocation tags
- **Compliance**: Prevents non-compliant resource creation
- **Automation**: Reduces manual tag management overhead
- **Visibility**: Centralized view of tag compliance

## Best Practices Highlighted
- **Start Small**: Begin with a few critical tags and expand gradually
- **Test First**: Use detective mode before enabling enforcement
- **Clear Values**: Define specific allowed tag values for consistency
- **Documentation**: Maintain clear tag taxonomy and policies
- **Regular Review**: Periodically review and update tag policies

## Common Tag Policy Patterns

### Environment Classification
```json
"Environment": {
  "tag_key": {"@@assign": "Environment"},
  "tag_value": {"@@assign": ["Production", "Development", "Staging"]},
  "enforced_for": {"@@assign": ["*:*"]}
}
```

### Cost Center Tracking
```json
"CostCenter": {
  "tag_key": {"@@assign": "CostCenter"},
  "tag_value": {"@@assign": ["1001", "1002", "1003"]},
  "enforced_for": {"@@assign": ["ec2:instance", "rds:db"]}
}
```

### Project Assignment
```json
"Project": {
  "tag_key": {"@@assign": "Project"},
  "enforced_for": {"@@assign": ["ec2:instance"]}
}
```

## Troubleshooting Tips
- **Policy not enforcing**: Verify tag policies are enabled in Organizations
- **Access denied**: Ensure management account permissions
- **Resources not compliant**: Check if resources were created before policy attachment
- **Policy conflicts**: Review inherited policies from parent OUs
- **Enforcement issues**: Verify resource type format in policy

## Verification Steps
After implementation:
1. Confirm policy is attached to correct OUs
2. Test enforcement by attempting non-compliant tagging
3. Review compliance reports in Resource Groups
4. Verify cost allocation tags are properly applied
5. Check that new resources follow tagging standards

## Advanced Scenarios
- **Multi-level inheritance**: Policies from root, OU, and account levels
- **Case sensitivity**: Enforcing specific case for tag keys and values
- **Conditional enforcement**: Different rules for different resource types
- **Exception handling**: Managing resources that cannot be tagged

## Next Steps
After this demonstration, participants should:
1. Design comprehensive tag policies for their organization
2. Implement policies gradually across OUs
3. Set up compliance monitoring and reporting
4. Train teams on new tagging requirements
5. Integrate tag policies with cost allocation strategies

## Documentation References
- [Tag policies - AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html)
- [Getting started with tag policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies-getting-started.html)
- [Tag policy syntax and examples](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies-syntax.html)
- [Best Practices for Tagging AWS Resources](https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/tagging-best-practices.html)
- [Using Tag Editor](https://docs.aws.amazon.com/tag-editor/latest/userguide/tag-editor.html)

---
*Demo Duration: 5 minutes*  
*Skill Level: Intermediate to Advanced*  
*Tools Used: AWS Console, AWS Organizations*
