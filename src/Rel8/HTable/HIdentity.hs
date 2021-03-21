{-# LANGUAGE FlexibleInstances #-}
{-# language DataKinds #-}
{-# language GADTs #-}
{-# language InstanceSigs #-}
{-# language RankNTypes #-}
{-# language ScopedTypeVariables #-}
{-# language TypeFamilies #-}
{-# language UndecidableInstances #-}

module Rel8.HTable.HIdentity ( HIdentity(..) ) where

-- base
import Data.Kind (Type)
import Data.Type.Equality ( type (:~:)(Refl) ) 

-- rel8
import Rel8.Context ( Meta( Meta ) )
import Rel8.HTable ( HTable( HField, htabulate, htraverse, hfield, hdbtype ), HAllColumns )
import Rel8.Info ( HasInfo( info ), Column (InfoColumn) )


-- | A single-column higher-kinded table. This is primarily useful for
-- facilitating generic-deriving of higher kinded tables.
newtype HIdentity a (f :: Meta -> Type) = HIdentity { unHIdentity :: f a }


instance HasInfo a => HTable (HIdentity ('Meta d a)) where
  type HField (HIdentity ('Meta d a)) = (:~:) ('Meta d a)
  type HAllColumns (HIdentity ('Meta d a)) c = c a

  hfield (HIdentity a) Refl = a
  htabulate f = HIdentity $ f Refl
  hdbtype = HIdentity $ InfoColumn info
  htraverse f (HIdentity a) = HIdentity <$> f a
