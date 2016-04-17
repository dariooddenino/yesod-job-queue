import qualified Prelude as P
import ClassyPrelude.Yesod
import Yesod
import Yesod.JobQueue
import Control.Concurrent
import Database.Persist.Sqlite
import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.Logger (runStderrLoggingT)


-- Handlers
-- getHomeR :: Handler Html
getHomeR = defaultLayout $ do
    setTitle "JobQueue sample"
    [whamlet|
        <h1>Hello
    |]

-- Yesod Persist settings (Nothing special here)
share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person
  name String
  age Int
  deriving Show
|]
instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB action = do
        app <- getYesod
        runSqlPool action $ appConnPool app


-- Make Yesod App that have ConnectionPool, JobState
data App = App {
    appConnPool :: ConnectionPool
    , appDBConf :: SqliteConf
    , appJobState :: JobState
    }
instance Yesod App
mkYesod "App" [parseRoutes|
/ HomeR GET
/job JobQueueR JobQueue getJobQueue -- ^ JobQueue API and Manager
|]

-- JobQueue settings
data MyJobType = AggregationUser | PushNotification deriving (Show, Read, Enum, Bounded)
instance JobInfo MyJobType where
        describe AggregationUser = "aggregate users"
        describe _ = "No information"

instance YesodJobQueue App SqliteConf where
    type JobType App = MyJobType
    getJobState = appJobState
    jobDBConfig app = (appDBConf app, appConnPool app)
    runJob app AggregationUser = do
        us <- runDBJob $ selectList ([] :: [Filter Person]) []
        liftIO $ threadDelay $ 10 * 1000 * 1000
        putStrLn "complate job!"
    runJob app PushNotification = do
        putStrLn "send norification!"
    jobManagerJSUrl _ = "http://localhost:3001/dist/app.bundle.js" -- use for development with "npm run bs"

-- Main
main :: IO ()
main = runStderrLoggingT $
       withSqlitePool (sqlDatabase dbConf) (sqlPoolSize dbConf) $ \pool -> liftIO $ do
           runResourceT $ flip runSqlPool pool $ do
               runMigration migrateAll
               insert $ Person "test" 28
           jobState <- newJobState -- ^ create JobState
           let app = App pool dbConf jobState
           startDequeue app
           warp 3000 app
  where dbConf = SqliteConf "test.db3" 4
