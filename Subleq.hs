module Main where

import System.IO
import Data.Word
import qualified Data.ByteString as B

import Control.Monad.State

main = withBinaryFile "code.sblq" WriteMode $ \h ->
 B.hPut h . B.pack $ code


type Fresh a = State ([Either Word8 Word8],[Word8],[(Word8,Word8)]) a

cells = ([],[0..],[])

runFresh :: Fresh a -> [Word8]
runFresh m = case execState m cells of
 (code,_,dat) -> map f code ++ map snd dat
   where f (Left c) = fromIntegral (length code) + c
         f (Right e) = e

fresh :: Word8 -> Fresh Word8
fresh val = do (code,cell:cells,table) <- get
               put (code,cells,table++[(cell,val)])
               return cell

used :: Word8 -> Fresh ()
used n = do (code,cells,table) <- get
            put (code,filter (/= n) cells,table)

place :: Fresh Word8
place = do (code,_,_) <- get
           return (fromIntegral (length code))

emit :: [Either Word8 Word8] -> Fresh ()
emit cod = do (code,cells,table) <- get
              put (code ++ cod,cells,table)

data Arith = Immediate Word8 | Negate Arith | Add Arith Arith

pass1 (Immediate n) = do cell <- fresh n
                         return cell
pass1 (Negate v) = do cell <- pass1 v
                      temp <- fresh 0
                      p <- place
                      emit [Left cell,Left temp,Right (p+3)]
                      return temp
pass1 (Add p q) = do cell1 <- pass1 p
                     cell2 <- pass1 (Negate q)
                     p <- place
                     emit [Left cell2, Left cell1, Right (p+3)]
                     return cell1

code = runFresh (pass1 (Add (Negate (Immediate 7)) (Negate (Negate (Immediate 66)))))
