package com.example.claimsservice.model;

import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;


@DynamoDbBean
public class Claim {
    private String claimId;
    private String status;
    private String customerId;
    private String incidentDate;
    private String description;
    
    public Claim() {}

    public Claim(String claimId, String status, String customerId, String incidentDate, String description) {
        this.claimId = claimId;
        this.status = status;
        this.customerId = customerId;
        this.incidentDate = incidentDate;
        this.description = description;
    }

    @DynamoDbPartitionKey
    public String getClaimId() {
        return claimId;
    }

    public void setClaimId(String claimId) {
        this.claimId = claimId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public String getIncidentDate() {
        return incidentDate;
    }

    public void setIncidentDate(String incidentDate) {
        this.incidentDate = incidentDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
