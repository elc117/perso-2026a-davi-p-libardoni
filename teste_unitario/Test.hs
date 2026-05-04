module Main where

import Test.HUnit
import Functions
import Data.Time

-- testes sem banco de dados e sem scotty, vou adicionar dados de exemplo em uma lista de Books
-- essa lista é o equivalente ao que seria puxado do banco de dados, nesse mesmo formato
sampleBooks :: [Book]
sampleBooks =
    [ Book 1 "Dune" "Frank Herbert" 1965 (fromGregorian 2024 1 10) "finished" "Sci-Fi" 4.8 412 412 Nothing
    , Book 2 "Dune Messiah" "Frank Herbert" 1969 (fromGregorian 2024 1 22) "finished" "Sci-Fi" 4.1 256 256 Nothing
    , Book 3 "The Hobbit" "J.R.R. Tolkien" 1937 (fromGregorian 2024 2 5) "reading" "Fantasy" 4.5 310 150 (Just (fromGregorian 2024 1 20))
    , Book 4 "The Fellowship of the Ring" "J.R.R. Tolkien" 1954 (fromGregorian 2024 2 18) "finished" "Fantasy" 4.7 423 423 Nothing
    , Book 5 "Pride and Prejudice" "Jane Austen" 1813 (fromGregorian 2026 3 3) "finished" "Classic" 4.2 279 279 Nothing
    , Book 6 "Emma" "Jane Austen" 1815 (fromGregorian 2023 3 20) "finished" "Classic" 4.0 474 474 Nothing
    , Book 7 "Neuromancer" "William Gibson" 1984 (fromGregorian 2024 1 30) "finished" "Sci-Fi" 4.3 271 271 Nothing
    , Book 8 "The Left Hand of Darkness" "Ursula K. Le Guin" 1969 (fromGregorian 2026 2 9) "finished" "Sci-Fi" 4.4 304 304 Nothing
    ]

-- para simplificar, os testes de filtro vão comparar apenas a lista
-- de nomes dos livros que serão filtrados 
titles :: [Book] -> [String]
titles = map name

testFilterAuthor :: String -> [String] -> Test
testFilterAuthor auth expected = TestCase $ assertEqual "filtrados p/ autor" expected (titles (filterByAuthor sampleBooks auth))  

testFilterGenre :: String -> [String] -> Test
testFilterGenre gen expected = TestCase $ assertEqual "filtrados p/ genero" expected (titles (filterByGenre sampleBooks gen))

testFilterRating :: Double -> [String] -> Test
testFilterRating rat expected = TestCase $ assertEqual "filtrados p/ nota" expected (titles (filterByRating sampleBooks rat))

testFilterMonthRead :: Int -> Int -> [String] -> Test
testFilterMonthRead m y expected = TestCase $ assertEqual "filtrados p/ mês" expected (titles(filterByMonthRead sampleBooks m y))

testFilterYearRead :: Int -> [String] -> Test
testFilterYearRead y expected = TestCase $ assertEqual "filtrados p/ ano" expected (titles(filterByYearRead sampleBooks y))

testPagesByMonth :: Int -> Int -> Int -> Test
testPagesByMonth m y expected = TestCase $ assertEqual "páginas p/ mes" expected $ pagesByMonth sampleBooks m y

testPagesByYear :: Int -> Int -> Test
testPagesByYear y expected = TestCase $ assertEqual "páginas p/ ano" expected $ pagesByYear sampleBooks y

testOrderByDate :: Bool -> [String] -> Test
testOrderByDate dir expected = TestCase $ assertEqual ("order by " ++ (if dir then "old" else "new")) expected (titles(orderByDateRead sampleBooks dir))

tests :: Test
tests = TestList
    [
        TestLabel "filtro autor Frank Herbert" $ testFilterAuthor "Frank Herbert" ["Dune","Dune Messiah"]
        ,TestLabel "filtro genero Fantasy" $ testFilterGenre "Fantasy" ["The Hobbit","The Fellowship of the Ring"]
        ,TestLabel "filtro rating >= 4.5" $ testFilterRating 4.5 ["Dune","The Hobbit","The Fellowship of the Ring"]
        ,TestLabel "filtro lido em jan/2024" $ testFilterMonthRead 1 2024 ["Dune","Dune Messiah","Neuromancer"]
        ,TestLabel "paginas lidas em fev/2024" $ testPagesByMonth 2 2024 (310 + 423)
        ,TestLabel "paginas lidas em 2026" $ testPagesByYear 2026 (279 + 304)
        ,TestLabel "ordenado por mais antigo" $ testOrderByDate True ["Emma","Dune","Dune Messiah","Neuromancer","The Hobbit","The Fellowship of the Ring","The Left Hand of Darkness","Pride and Prejudice"]
        ,TestLabel "ordenado por mais novo" $ testOrderByDate False ["Pride and Prejudice","The Left Hand of Darkness","The Fellowship of the Ring","The Hobbit","Neuromancer","Dune Messiah","Dune","Emma"]
    ]

main :: IO Counts
main = runTestTT tests