package edu.haut.gradms.model;

import java.sql.Timestamp;

public class Message {
    private int messageId;
    private int senderUserId;
    private int receiverUserId;
    private String content;
    private Timestamp sentAt;
    private boolean isRead;
    private Timestamp readAt;

    public int getMessageId() { return messageId; }
    public void setMessageId(int messageId) { this.messageId = messageId; }

    public int getSenderUserId() { return senderUserId; }
    public void setSenderUserId(int senderUserId) { this.senderUserId = senderUserId; }

    public int getReceiverUserId() { return receiverUserId; }
    public void setReceiverUserId(int receiverUserId) { this.receiverUserId = receiverUserId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public Timestamp getReadAt() { return readAt; }
    public void setReadAt(Timestamp readAt) { this.readAt = readAt; }
}