{-# language DataKinds #-}
{-# language FlexibleContexts #-}
{-# language FlexibleInstances #-}
{-# language MultiParamTypeClasses #-}
{-# language NamedFieldPuns #-}
{-# language ScopedTypeVariables #-}
{-# language TypeApplications #-}
{-# language TypeFamilies #-}
{-# language UndecidableInstances #-}
{-# language ViewPatterns #-}

module Rel8.Table.Name
  ( namesFromLabels
  , namesFromLabelsWith
  , showLabels
  , showNames
  )
where

-- base
import Data.Foldable ( fold )
import Data.Functor.Const ( Const( Const ), getConst )
import Data.List.NonEmpty ( NonEmpty, intersperse, nonEmpty )
import Data.Maybe ( fromMaybe )
import Prelude

-- rel8
import Rel8.Schema.HTable ( htabulate, htabulateA, hfield, hspecs )
import Rel8.Schema.Name ( Name( Name ) )
import Rel8.Schema.Spec ( Spec(..) )
import Rel8.Table ( Table(..) )


-- | Construct a table in the 'Name' context containing the names of all
-- columns. Nested column names will be combined with @/@.
--
-- See also: 'namesFromLabelsWith'.
namesFromLabels :: Table Name a => a
namesFromLabels = namesFromLabelsWith go
  where
    go = fold . intersperse "/"


-- | Construct a table in the 'Name' context containing the names of all
-- columns. The supplied function can be used to transform column names.
--
-- This function can be used to generically derive the columns for a
-- 'TableSchema'. For example,
--
-- @
-- myTableSchema :: TableSchema (MyTable Name)
-- myTableSchema = TableSchema
--   { columns = namesFromLabelsWith last
--   }
-- @
--
-- will construct a 'TableSchema' where each columns names exactly corresponds
-- to the name of the Haskell field.
namesFromLabelsWith :: Table Name a
  => (NonEmpty String -> String) -> a
namesFromLabelsWith f = fromColumns $ htabulate $ \field ->
  case hfield hspecs field of
    Spec {labels} -> Name (f (renderLabels labels))


showLabels :: forall a. Table (Context a) a => a -> [NonEmpty String]
showLabels _ = getConst $
  htabulateA @(Columns a) $ \field -> case hfield hspecs field of
    Spec {labels} -> Const (pure (renderLabels labels))


showNames :: forall a. Table Name a => a -> NonEmpty String
showNames (toColumns -> names) = getConst $
  htabulateA @(Columns a) $ \field -> case hfield names field of
    Name name -> Const (pure name)


renderLabels :: [String] -> NonEmpty String
renderLabels labels = fromMaybe (pure "anon") (nonEmpty labels )
