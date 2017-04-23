User.create!([
  {name: "super", password_digest: "$2a$10$4QkHdD3a.jX5f4F46pUVFu8XkWIsFVyzFaQfZNb.gAE357x5szLtq"},
  {name: "super2", password_digest: "$2a$10$4QkHdD3a.jX5f4F46pUVFu8XkWIsFVyzFaQfZNb.gAE357x5szLtq"}
])
Topic.create!([
  {topicId: "41429"}
])
Post.create!([
  {post_id: "8756350", post_user_name: "yamakawa5", topic_id: 1},
  {post_id: "8756352", post_user_name: "yamakawa5", topic_id: 1},
  {post_id: "8756556", post_user_name: "yamakawa5", topic_id: 1},
  {post_id: "8756557", post_user_name: "yamakawa5", topic_id: 1}
])
