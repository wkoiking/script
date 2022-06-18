{-# LANGUAGE OverloadedStrings #-}
module Windows where

import Turtle
import qualified Data.Text (Text)
import qualified Data.Text as T (pack, unwords, intercalate)
import Control.Monad
import Data.List

mainWindows :: IO ()
mainWindows = do
    forM_ hostAddrs $ \ hostAddr -> do
        shell (T.unwords ["net use", "H:", dstDirectory hostAddr hostName, pass, "/user:" <> hostAddr <> "\\" <> hostName]) empty
        shell (T.unwords ["copy", "/Y", srcFilePath, "H:\\" <> fileName]) empty
        shell (T.unwords ["net use", "H:", "/delete"]) empty
        -- make .cmd file
        -- modify registory
        -- start / end process ==> use schtasks

hostName :: Text
hostName = "mega"
pass :: Text
pass = "mega2018"

srcFilePath :: Text
srcFilePath = T.intercalate "\\" ["C:", "test", fileName]
-- intercalate "\\" ["C:", "Users", "nao", "VDU", ".stack-work", "install", "65995373", "bin", fileName]

dstDirectory :: Text -> Text -> Text
dstDirectory hostAddr hostName = T.intercalate "\\" ["\\\\" <> hostAddr <> "\\c$", "Users", hostName, "VDU"]

fileName :: Text
fileName = "newfile.txt"

hostAddrs :: [Text]
hostAddrs = map (("172.21.102." <>) . T.pack . show) hostLastOctets

hostLastOctets :: [Int]
hostLastOctets = [22]

-- net use H: \\172.21.102.6\c$\test nspj2015 /user:172.21.102.6\dmrc
-- copy testfile.txt H:\newTestfile.txt
-- net use H: /delete

-- C:\test>schtasks /Create /S 172.21.102.22 /U mega /P mega2018 /TN StartCALC /SC ONLOGON /TR C:\windows\system32\calc.exe
-- 成功: スケジュール タスク "StartCALC" は正しく作成されました。
-- C:\test>schtasks /Run       /S 172.21.102.22 /U mega /P mega2018 /TN StartCALC
-- 成功: スケジュール タスク "StartCALC" の実行が試行されました。
-- C:\test>schtasks /Delete /F /S 172.21.102.22 /U mega /P mega2018 /TN StartCALC
-- 成功: スケジュール タスク "StartCALC" は正しく削除されました。

-- C:\Users\nao\VDU>schtasks /Create /F /S 172.21.102.22 /U mega /P mega2018 /TN StopCALC /SC ONLOGON /IT /TR "taskkill /FI \"IMAGENAME eq Calc*\" /F"
-- 成功: スケジュール タスク "StopCALC" は正しく作成されました。
-- C:\Users\nao\VDU>schtasks /Run /S 172.21.102.22 /U mega /P mega2018 /TN StartCALC
-- 成功: スケジュール タスク "StartCALC" の実行が試行されました。
-- C:\Users\nao\VDU>schtasks /Run /S 172.21.102.22 /U mega /P mega2018 /TN StopCALC
-- 成功: スケジュール タスク "StopCALC" の実行が試行されました。
