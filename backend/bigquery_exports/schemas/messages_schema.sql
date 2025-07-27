CREATE TABLE IF NOT EXISTS `ustam_analytics.messages` (
  message_id INTEGER NOT NULL,
  sender_id INTEGER NOT NULL,
  recipient_id INTEGER NOT NULL,
  message_type STRING,
  job_id INTEGER,
  quote_id INTEGER,
  is_read BOOLEAN,
  created_at TIMESTAMP,
  read_at TIMESTAMP
);