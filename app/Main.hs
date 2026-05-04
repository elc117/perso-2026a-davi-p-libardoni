{-# LANGUAGE OverloadedStrings #-}
module Main where

import Functions
import APICalls (searchBooks)
import DBAccess

import Web.Scotty
import Database.PostgreSQL.Simple
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Static (staticPolicy, addBase)
import Network.HTTP.Types.Status (notFound404)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)
import qualified Data.Text.Lazy as TL
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString.Char8 as BS

main :: IO ()
main = do
  -- pick port: env PORT (Codespaces/Render/Heroku) or default 3000
  mPort <- lookupEnv "PORT"
  let port = maybe 3000 id (mPort >>= readMaybe)

  mDbUrl <- lookupEnv "DATABASE_URL"
  dbUrl <- maybe (fail "DATABASE_URL is not set") (pure . BS.pack) mDbUrl
  conn <- connectPostgreSQL dbUrl
  _ <- initDB conn

  mStaticDir <- lookupEnv "STATIC_DIR"
  let staticDir = maybe "static" id mStaticDir

  scotty port $ do
    middleware logStdoutDev
    middleware (staticPolicy (addBase staticDir))

    get "/" $ do
      file (staticDir ++ "/readlog.html")

    get "/books" $ do
      allBooks <- liftIO (getBooks conn)
      
      allParams <- params
      
      let mAuthor = fmap TL.unpack (lookup "author" allParams)
          mGenre  = fmap TL.unpack (lookup "genre" allParams)
          mSort   = fmap TL.unpack (lookup "sort" allParams)
          
          mRatingStr = fmap TL.unpack (lookup "rating" allParams)
          mRating    = mRatingStr >>= readMaybe :: Maybe Double

          filteredByAuthor = maybe allBooks (filterByAuthor allBooks) mAuthor
          filteredByGenre  = maybe filteredByAuthor (filterByGenre filteredByAuthor) mGenre
          filteredByRating = maybe filteredByGenre (filterByRating filteredByGenre) mRating
          
          sortedList = case mSort of
            Just "author" -> orderByAuthor filteredByRating True
            Just "rating" -> orderByRating filteredByRating False
            Just "pages"  -> orderByPages filteredByRating False
            Just "title"  -> orderByTitle filteredByRating True
            _             -> orderByDateRead filteredByRating False
            
      json sortedList

    get "/book/search" $ do
      q <- (param "q" :: ActionM TL.Text)
      result <- liftIO (searchBooks (TL.unpack q))
      json result

    post "/book/add" $ do
      book <- (jsonData :: ActionM BookInput)
      _ <- liftIO (insertBook conn book)
      json ("ok" :: TL.Text)

    patch "/book/:id" $ do
      bid <- (param "id" :: ActionM Int)
      upd <- (jsonData :: ActionM BookUpdate)
      n <- liftIO (updateBook conn bid upd)
      if n == 0
        then status notFound404
        else json ("ok" :: TL.Text)

    delete "/book/:id" $ do
      bid <- (param "id" :: ActionM Int)
      result <- liftIO (removeBook conn bid)
      if result == 0
        then status notFound404
        else json ("ok" :: TL.Text)

  close conn