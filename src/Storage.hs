module Storage where

import Data.ByteString as B
import Data.Hashable
import System.Posix
import System.Directory.Extra
import Control.Monad.Extra
import Data.Function.Slip
import Data.Composition

type Bucket = String
type ObjID = Int
type Content = ByteString

store :: Bucket -> ObjID -> B.ByteString -> IO ()
store bucket obj content =
    whenM (not <$> objIdentical bucket obj content) $
    ensureBucketExists bucket <>
    whenM (not <$> isDup) store <>
    whenM isOverride unref <>
    ref
                where
                isOverride = fileExist $ path bucket obj "/objects/"
                isDup = (fileExist .: data_path) bucket content
                obj_paths = path bucket obj
                storage = data_path bucket content
                store = B.writeFile storage content
                ref = createLink storage (obj_paths "/objects/")
                      <> createSymbolicLink storage (obj_paths "/refs/")
                unref = removeLink (obj_paths "/objects/")
                        <> whenM ((== 1) <$> exemplarOf bucket obj)
                           (unstore $ obj_paths "/refs/")
                        <> removeLink (obj_paths "/refs/")


objIdentical b obj content = fileExist (path b obj "/objects/")
                                  &&^ fmap (== data_path b content)
                                      (readSymbolicLink $ path b obj "/refs/")

unstore = removeLink <=< readSymbolicLink

retrieve :: Bucket -> ObjID -> IO ByteString
retrieve = B.readFile .: slipl path "/objects/"

delete :: Bucket -> ObjID -> IO ()
delete bucket obj = whenM ((== 2) <$> exemplarOf bucket obj) (unstore data_ref)
                       <> unref
                where
                obj_paths = path bucket obj
                data_ref = obj_paths "/refs/"
                unref = removeLink (obj_paths "/objects/")
                     <> removeLink data_ref

ifObj bucket obj f = whenMaybeM
                        (fileExist $ path bucket obj "/objects/") $
                        f bucket obj

data_path :: Bucket -> Content -> FilePath
data_path bucket content = bucket <> "/store/" <> (show . hash) content

exemplarOf :: Bucket -> ObjID -> IO LinkCount
exemplarOf b i = fmap linkCount $
                 getFileStatus <=< readSymbolicLink $
                 b <> "/refs/" <> show i

path ::  Bucket -> ObjID -> String -> FilePath
path b obj what =  b <> what <> show obj

ensureBucketExists bucket = foldMap (
                                createDirectoryIfMissing True . (bucket <>))
                                ["/refs/", "/objects/", "/store/"]
