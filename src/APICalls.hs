{-# LANGUAGE OverloadedStrings #-}
module APICalls where

import Data.Aeson (Value, decode)
import Data.Text (pack)
import Data.Text.Encoding (encodeUtf8)
import System.Environment (lookupEnv)
import Network.HTTP.Simple (getResponseBody,httpLBS,parseRequest,setRequestQueryString)

searchBooks :: String -> IO (Maybe Value)
searchBooks query = do
  mApiKey <- lookupEnv "GOOGLE_BOOKS_API_KEY"
  req <- parseRequest "https://www.googleapis.com/books/v1/volumes"
  let keyParam = case mApiKey of
        Nothing -> []
        Just k -> [("key", Just (encodeUtf8 (pack k)))]
      queryParams = ("q", Just (encodeUtf8 (pack query))) : keyParam
      reqWithQuery = setRequestQueryString queryParams req
  resp <- httpLBS reqWithQuery
  pure (decode (getResponseBody resp))
