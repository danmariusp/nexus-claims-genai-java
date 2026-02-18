package com.example.claimsservice.controller;

import com.example.claimsservice.model.Claim;
import com.example.claimsservice.service.BedrockService;
import com.example.claimsservice.service.S3Service;
import org.springframework.web.bind.annotation.*;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;
import software.amazon.awssdk.enhanced.dynamodb.Key;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/claims")
public class ClaimController {

    private final DynamoDbTable<Claim> claimTable;
    private final S3Service s3Service;
    private final BedrockService bedrockService;

    public ClaimController(DynamoDbEnhancedClient dynamoDbClient, S3Service s3Service, BedrockService bedrockService) {
        this.claimTable = dynamoDbClient.table("Claims", TableSchema.fromBean(Claim.class));
        this.s3Service = s3Service;
        this.bedrockService = bedrockService;
    }

    @GetMapping("/{id}")
    public Claim getClaim(@PathVariable String id) {
        return claimTable.getItem(Key.builder().partitionValue(id).build());
    }

    @PostMapping("/{id}/summarize")
    public Map<String, String> summarizeClaim(@PathVariable String id) {
        // 1. Get Claim Status
        Claim claim = getClaim(id);
        String status = (claim != null) ? claim.getStatus() : "Unknown";

        // 2. Get Notes from S3
        String notes = s3Service.getClaimNotes(id);

        // 3. Generate Summary
        String summary = bedrockService.summarizeClaim(notes);

        Map<String, String> response = new HashMap<>();
        response.put("claimId", id);
        response.put("status", status);
        response.put("notes_summary", summary);
        
        return response;
    }
}
