DROP TABLE IF EXISTS user, person, group, organizer;
DROP TABLE IF EXISTS follows, friendship;
DROP TABLE IF EXISTS playlist, userCreatesPlaylist, musician, track, playsTrack;
DROP TABLE IF EXISTS place, future_concert, finished_concert;
DROP TABLE IF EXISTS group_review, track_review, place_review, concert_review;
DROP TABLE IF EXISTS post, medie;
DROP TABLE IF EXISTS genre, sub_genre;

-- BASIC ENTITIES (4 tables)

CREATE TABLE user (
  user_id INT PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  bio VARCHAR(255) NOT NULL,
  -- todo fix this cause it doesnt work:
  CONSTRAINT user_has_subentity CHECK (
    EXISTS (SELECT * FROM person WHERE person.user_id = user.user_id)
    OR EXISTS (SELECT * FROM group WHERE group.user_id = user.user_id)
    OR EXISTS (SELECT * FROM organizer WHERE organizer.user_id = user.user_id)
  )
);

CREATE TABLE person (
  person_id INT PRIMARY KEY,
  user_id INT,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  birth_date DATE NOT NULL,
  verified_musician BOOLEAN NOT NULL DEFAULT false,
  FOREIGN KEY (user_id) REFERENCES user (user_id)
);

CREATE TABLE group (
  group_id INT PRIMARY KEY,
  user_id INT,
  music_group_id INT,
  group_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (music_group_id) REFERENCES music_group (music_group_id)
 );

CREATE TABLE organizer (
  organizer_id INT PRIMARY KEY,
  user_id INT,
  organizer_name VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user (user_id)
);

-- FOLLOW AND FRIENDSHIP RELATIONSHIP (2 tables)

CREATE TABLE follows (
  follower_id INT NOT NULL,
  followed_id INT NOT NULL,
  PRIMARY KEY (follower_id, followed_id),
  FOREIGN KEY (follower_id) REFERENCES user (user_id),
  FOREIGN KEY (followed_id) REFERENCES user (user_id)
);

CREATE TABLE friendship (
  user1_id INT NOT NULL,
  user2_id INT NOT NULL,
  PRIMARY KEY (user1_id, user1_id),
  FOREIGN KEY (user1_id) REFERENCES user (user_id),
  FOREIGN KEY (user2_id) REFERENCES user (user_id)
);


-- TRACKS AND PLAYLISTS (6 tables)

CREATE TABLE playlist (
  playlist_id INT PRIMARY KEY,
  playlist_name VARCHAR(255) NOT NULL,
  description VARCHAR(255) NOT NULL,
  user_id INT,

  -- todo fix this cause it doesnt work:
  -- peut etre un compteur de playlists crees dans user est une meilleure idee
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  CONSTRAINT user_playlist_limit CHECK (
    (SELECT COUNT(*) FROM Playlist WHERE user_id = user_id) <= 10
  )
);

CREATE TABLE userCreatesPlaylist (
  user_id INT NOT NULL,
  playlist_id INT NOT NULL,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (playlist_id) REFERENCES playlist (playlist_id)
);

CREATE TABLE musician (
    musician_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE music_group (
    music_group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(255) NOT NULL
);

CREATE TABLE track (
  track_id INT PRIMARY KEY,
  title VARCHAR(255) NOT NULL
);

CREATE TABLE playsTrack (
  musician_id INT,
  track_id INT,
  FOREIGN KEY (musician_id) REFERENCES musician (musician_id),
  FOREIGN KEY (track_id) REFERENCES track (track_id),
  PRIMARY KEY (musician_id, track_id)
);

-- CONCERTS AND PLACES (3 tables)

CREATE TABLE place (
  place_id INT PRIMARY KEY,
  place_name VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL,
  exterior BOOLEAN NOT NULL,
  max_capacity INT NOT NULL
);

CREATE TABLE future_concert (
  concert_id INT PRIMARY KEY,
  concert_name VARCHAR(255) NOT NULL,
  concert_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  start_time TIME NOT NULL,
  ticket_price INT NOT NULL,
  children_allowed BOOLEAN NOT NULL DEFAULT false,
  attendance INT NOT NULL,
  place_id INT,
  FOREIGN KEY (place_id) REFERENCES place (place_id)
);

CREATE TABLE finished_concert (
  concert_id INT PRIMARY KEY,
  concert_name VARCHAR(255) NOT NULL,
  concert_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  start_time TIME NOT NULL,
  ticket_price INT NOT NULL,
  children_allowed BOOLEAN NOT NULL DEFAULT false,
  place_id INT,
  FOREIGN KEY (place_id) REFERENCES place (place_id)
);

-- REVIEWS (avis) (5 tables)

CREATE TABLE review (
  review_id INT PRIMARY KEY,
  review_timestamp TIME NOT NULL,
  review_grade INT NOT NULL,
  review_comment VARCHAR(255) NOT NULL,
  CHECK (review_grade >= 0 AND review_grade <= 10)
);

CREATE TABLE group_review (
  review_id INT,
  user_id INT,
  group_id INT,
  FOREIGN KEY (review_id) REFERENCES review (review_id),
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (group_id) REFERENCES group (group_id)
);

CREATE TABLE track_review (
  review_id INT,
  user_id INT,
  track_id INT,
  FOREIGN KEY (review_id) REFERENCES review (review_id),
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (track_id) REFERENCES track (track_id)
);

CREATE TABLE place_review (
  review_id INT,
  user_id INT,
  place_id INT,
  FOREIGN KEY (review_id) REFERENCES review (review_id),
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (place_id) REFERENCES place (place_id)
);

CREATE TABLE concert_review (
  review_id INT,
  user_id INT,
  concert_id INT,
  FOREIGN KEY (review_id) REFERENCES review (review_id),
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (concert_id) REFERENCES finished_concert (concert_id)
);

-- POSTS (2 tables)

CREATE TABLE post (
    post_id INT PRIMARY KEY,
    post_timestamp TIME NOT NULL,
    post_content VARCHAR(255) NOT NULL,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES user (user_id)
);

CREATE TABLE media (
    media_id INT PRIMARY KEY,
    media_title VARCHAR(255) NOT NULL,
    post_id INT,
    FOREIGN KEY (post_id) REFERENCES post (post_id)
);

-- GENRES (2 tables)

CREATE TABLE genre (
  genre_id PRIMARY KEY,
  genre_title VARCHAR(255) NOT NULL,
  genre_description VARCHAR(255) NOT NULL
);

CREATE TABLE sub_genre (
  sub_genre_title VARCHAR(255) NOT NULL,
  parent_genre INT,
  FOREIGN KEY (parent_genre) REFERENCES genre (genre_id),
  PRIMARY KEY(parent_genre, sub_genre_title)
);

-- TAGS (8 tables)

CREATE TABLE tag (
  tag_id INT PRIMARY KEY,
  tag_content VARCHAR(255)
);

CREATE TABLE post_tag(
  tag_id INT,
  post_id INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (post_id) REFERENCES post (post_id)
);

CREATE TABLE review_tag(
  tag_id INT,
  review_id INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (review_id) REFERENCES review (review_id)
);

CREATE TABLE future_concert_tag(
  tag_id INT,
  concert_id INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (concert_id) REFERENCES future_concert (concert_id)
);

CREATE TABLE finished_concert_tag(
  tag_id INT,
  concert_id INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (concert_id) REFERENCES finished_concert (concert_id)
);

CREATE TABLE place_tag(
  tag_id INT,
  place_id INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (place_id) REFERENCES place (place_id)
);

CREATE TABLE music_group_tag(
  tag_id INT,
  group_id INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (music_group_id) REFERENCES music_group (music_group_id)
);

CREATE TABLE genre_tag(
  tag_id INT,
  genre_id INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (genre_id) REFERENCES genre (genre_id)
);

CREATE TABLE sub_genre_tag(
  tag_id INT,
  sub_genre_title VARCHAR(255),
  parent_genre INT,
  FOREIGN KEY (tag_id) REFERENCES tag (tag_id),
  FOREIGN KEY (sub_genre_title) REFERENCES sub_genre (sub_genre_title),
  FOREIGN KEY (parent_genre) REFERENCES sub_genre (parent_genre)
);


-- END
