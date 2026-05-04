{-# LANGUAGE OverloadedStrings #-}
module Functions (Book(..), BookInput(..), BookUpdate(..), filterByAuthor, filterByGenre, filterByRating, filterByStatus, filterByQuery, orderByTitle, orderByAuthor, orderByRating, orderByPages, orderByDateRead, filterByMonthRead, filterByYearRead, pagesByMonth, pagesByYear) where

import Data.Char (toLower)
import Data.Aeson (FromJSON(..), ToJSON(..), object, withObject, (.:), (.=), (.:?))
import Data.List
import Data.Ord
import Data.Time
import Database.PostgreSQL.Simple.FromRow (FromRow(..),field)
import Database.PostgreSQL.Simple.ToRow (ToRow(..), toRow)

data Book = Book { 
 bookId :: Int,
 name :: String, 
 author :: String, 
 releaseDate :: Int, 
 readDate :: Day,
 bStatus :: String,
 genre :: String,
 rating :: Double,
 pages :: Int,
 currentPage :: Int,
 startDate :: Maybe Day
} deriving (Show)

data BookInput = BookInput {
    inName :: String,
    inAuthor :: String,
    inReleaseDate :: Int,
    inReadDate :: Day,
    inStatus :: String,
    inGenre :: String,
    inRating :: Double,
    inPages :: Int
} deriving (Show)

data BookUpdate = BookUpdate {
    upStatus :: String,
    upRating :: Double,
    upCurrentPage :: Int,
    upReadDate :: Day,
    upStartDate :: Maybe Day
} deriving (Show)

-- filtra por autor
filterByAuthor :: [Book] -> String -> [Book]
filterByAuthor books a = filter (\b -> a == author b) books

-- filtra por gênero
filterByGenre :: [Book] -> String -> [Book]
filterByGenre books g = filter (\b -> g == genre b) books

-- filtra por avaliação | >= r
filterByRating :: [Book] -> Double -> [Book]
filterByRating books r = filter (\b -> rating b >= r) books

-- filtra por status
filterByStatus :: [Book] -> String -> [Book]
filterByStatus books s = filter (\b -> s == bStatus b) books

-- filtra por query (busca no nome ou autor)
filterByQuery :: [Book] -> String -> [Book]
filterByQuery books q = filter match books
    where
        lowQ = map toLower q
        match b = lowQ `isInfixOf` map toLower (name b) || lowQ `isInfixOf` map toLower (author b)

-- ordena por titulo
orderByTitle :: [Book] -> Bool -> [Book]
orderByTitle books True = sortBy (comparing name) books
orderByTitle books False = sortBy (comparing (Down . name)) books

-- ordena por autor
orderByAuthor :: [Book] -> Bool -> [Book]
orderByAuthor books True = sortBy (comparing author) books
orderByAuthor books False = sortBy (comparing (Down . author)) books

-- ordena por avaliação
orderByRating :: [Book] -> Bool -> [Book]
orderByRating books True = sortBy (comparing rating) books
orderByRating books False = sortBy (comparing (Down . rating)) books

-- ordena por paginas
orderByPages :: [Book] -> Bool -> [Book]
orderByPages books True = sortBy (comparing pages) books
orderByPages books False = sortBy (comparing (Down . pages)) books

-- ordena por data lida | variavel bool True para mais antigos False para mais recentes
orderByDateRead :: [Book] -> Bool -> [Book]
orderByDateRead books True = sortBy (comparing readDate) books
orderByDateRead books False = sortBy (comparing (Down . readDate)) books

-- filtra por mês
filterByMonthRead :: [Book] -> Int -> Int -> [Book]
filterByMonthRead books month year = filter match books
    where
        match book =
            let 
                (y,m,_) = toGregorian(readDate book)
            in m == month && y == fromIntegral year

-- filtra por ano
filterByYearRead :: [Book] -> Int -> [Book]
filterByYearRead books year = filter match books
    where
        match book =
            let
                (y,_,_) = toGregorian(readDate book)
            in y == fromIntegral year

-- numero de paginas lidas por mês (conta simples, contabiliza o livro inteiro no mês que foi marcado como completo)
pagesByMonth :: [Book] -> Int -> Int -> Int
pagesByMonth books month year = sum (map pages (filterByMonthRead books month year))

-- paginas lidas em um ano
pagesByYear :: [Book] -> Int -> Int
pagesByYear books year = sum (map pages (filterByYearRead books year))

-- conversão de row do banco de dados para o tipo Book
instance FromRow Book where
    fromRow = Book <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

-- conversão do tipo Book para row do db
instance ToRow Book where
    toRow (Book bid n a r rd s g rt pgs cp sd) = toRow (bid, n, a, r, rd, s, g, rt, pgs, cp, sd)

instance ToJSON Book where
    toJSON (Book bid n a r rd s g rt pgs cp sd) =
        object
            [ "bookId" .= bid
            , "name" .= n
            , "author" .= a
            , "release_date" .= r
            , "read_date" .= rd
            , "status" .= s
            , "genre" .= g
            , "rating" .= rt
            , "pages" .= pgs
            , "current_page" .= cp
            , "start_date" .= sd
            ]

instance FromJSON BookInput where
    parseJSON = withObject "BookInput" $ \o ->
        BookInput
            <$> o .: "name"
            <*> o .: "author"
            <*> o .: "release_date"
            <*> o .: "read_date"
            <*> o .: "status"
            <*> o .: "genre"
            <*> o .: "rating"
            <*> o .: "pages"

instance FromJSON BookUpdate where
    parseJSON = withObject "BookUpdate" $ \o ->
        BookUpdate
            <$> o .: "status"
            <*> o .: "rating"
            <*> o .: "current_page"
            <*> o .: "read_date"
            <*> o .:? "start_date"