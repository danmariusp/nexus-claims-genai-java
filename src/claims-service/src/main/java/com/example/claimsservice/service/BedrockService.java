package com.example.claimsservice.service;

import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.bedrockruntime.BedrockRuntimeClient;
import software.amazon.awssdk.services.bedrockruntime.model.InvokeModelRequest;
import software.amazon.awssdk.services.bedrockruntime.model.InvokeModelResponse;

import org.springframework.beans.factory.annotation.Value;
import software.amazon.awssdk.core.SdkBytes;

@Service
public class BedrockService {

    private final BedrockRuntimeClient bedrockRuntimeClient;

    @Value("${aws.bedrock.modelId:anthropic.claude-3-sonnet-20240229-v1:0}")
    private String modelId;

    public BedrockService(BedrockRuntimeClient bedrockRuntimeClient) {
        this.bedrockRuntimeClient = bedrockRuntimeClient;
    }

    public String summarizeClaim(String claimNotes) {
        String prompt = "Please summarize the following claim notes:\n\n" + claimNotes;

        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.node.ObjectNode body = mapper.createObjectNode();
            body.put("anthropic_version", "bedrock-2023-05-31");
            body.put("max_tokens", 1000);
            
            com.fasterxml.jackson.databind.node.ObjectNode message = mapper.createObjectNode();
            message.put("role", "user");
            message.put("content", prompt);
            
            com.fasterxml.jackson.databind.node.ArrayNode messages = mapper.createArrayNode();
            messages.add(message);
            body.set("messages", messages);

            InvokeModelRequest request = InvokeModelRequest.builder()
                    .modelId(modelId)
                    .contentType("application/json")
                    .accept("application/json")
                    .body(SdkBytes.fromUtf8String(mapper.writeValueAsString(body)))
                    .build();

            InvokeModelResponse response = bedrockRuntimeClient.invokeModel(request);
            
            com.fasterxml.jackson.databind.JsonNode responseBody = mapper.readTree(response.body().asUtf8String());
            return responseBody.get("content").get(0).get("text").asText();
        } catch (Exception e) {
            throw new RuntimeException("Error invoking Bedrock", e);
        }
    }
}
