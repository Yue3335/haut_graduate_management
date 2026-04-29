package edu.haut.gradms.dao;

import edu.haut.gradms.config.DBUtil;
import edu.haut.gradms.model.Message;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDao {

    /**
     * 保存一条消息，sent_at 使用表默认 CURRENT_TIMESTAMP
     */
    public void saveMessage(int senderUserId, int receiverUserId, String content) {
        String sql = "INSERT INTO message (sender_user_id, receiver_user_id, content) " +
                "VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, senderUserId);
            ps.setInt(2, receiverUserId);
            ps.setString(3, content);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("保存消息失败", e);
        }
    }

    /**
     * 查询两个用户之间的所有对话（双向），按 sent_at / message_id 升序排序
     */
    public List<Message> findConversation(int userId1, int userId2) {
        String sql = "SELECT * FROM message " +
                "WHERE (sender_user_id = ? AND receiver_user_id = ?) " +
                "   OR (sender_user_id = ? AND receiver_user_id = ?) " +
                "ORDER BY sent_at ASC, message_id ASC";

        List<Message> list = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId1);
            ps.setInt(2, userId2);
            ps.setInt(3, userId2);
            ps.setInt(4, userId1);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Message m = new Message();
                    m.setMessageId(rs.getInt("message_id"));
                    m.setSenderUserId(rs.getInt("sender_user_id"));
                    m.setReceiverUserId(rs.getInt("receiver_user_id"));
                    m.setContent(rs.getString("content"));
                    m.setSentAt(rs.getTimestamp("sent_at"));
                    m.setRead(rs.getBoolean("is_read"));
                    m.setReadAt(rs.getTimestamp("read_at"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询对话失败", e);
        }
        return list;
    }
}