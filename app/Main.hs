module Main where

import Api

import Servant
import Network.Wai.Handler.Warp
import Data.ByteString
import Data.Bool.HT

server :: Server ObjectStore
server x i = put_object :<|> get_object :<|> delete_object
    where
    y = "test"
    put_object _ = return $ x <> y <> show i

    get_object = return $ x <> show i

    delete_object = i < 50 ?: (return NoContent, throwError err404)

objectApi :: Proxy ObjectStore
objectApi = Proxy

app :: Application
app = serve objectApi server

main :: IO ()
main = run 8080 app
