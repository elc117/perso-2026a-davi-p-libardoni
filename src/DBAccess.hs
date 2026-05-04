{-# LANGUAGE OverloadedStrings #-}
module DBAccess (initDB,insertBook,getBooks,removeBook,updateBook) where

import Database.PostgreSQL.Simple
import Data.Int (Int64)
import Functions (Book(..), BookInput(..), BookUpdate(..))

-- Initialize database
initDB :: Connection -> IO Int64
initDB conn = execute_ conn
    "CREATE TABLE IF NOT EXISTS books \
    \ (id SERIAL PRIMARY KEY, \
    \  name TEXT NOT NULL, \
    \  author TEXT NOT NULL, \
    \  release_date INTEGER, \
    \  read_date DATE, \
    \  status TEXT, \
    \  genre TEXT, \
    \  rating REAL, \
    \  pages INTEGER, \
    \  current_page INTEGER DEFAULT 0)"

insertBook :: Connection -> BookInput -> IO Int64
insertBook conn book =
  execute conn
    "INSERT INTO books (name, author, release_date, read_date, status, genre, rating, pages, current_page) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)"
    (inName book, inAuthor book, inReleaseDate book, inReadDate book, inStatus book, inGenre book, inRating book, inPages book)

getBooks :: Connection -> IO [Book]
getBooks conn = query_ conn
  "SELECT id, name, author, release_date, read_date, status, genre, rating, pages, COALESCE(current_page, 0), start_date FROM books"

removeBook :: Connection -> Int -> IO Int64
removeBook conn bid = execute conn "DELETE FROM books WHERE id = ?" (Only bid)

updateBook :: Connection -> Int -> BookUpdate -> IO Int64
updateBook conn bid upd =
  execute conn
    "UPDATE books SET status = ?, rating = ?, current_page = ?, read_date = ?, start_date = ? WHERE id = ?"
    (upStatus upd, upRating upd, upCurrentPage upd, upReadDate upd, upStartDate upd, bid)