package orm

import (
	"centnet-fzmps/common/log"
	xtime "centnet-fzmps/common/time"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"time"
)

type Config struct {
	DSN         string         // database source name
	Active      int            // pool
	Idle        int            // pool
	IdleTimeout xtime.Duration // connect max life time
}

func NewMySQL(c *Config) (db *gorm.DB) {
	ormDB, err := gorm.Open(mysql.Open(c.DSN), &gorm.Config{})
	if err != nil {
		log.Error(err)
		return nil
	}

	// 设置日志
	ormDB.Config.Logger = logger.New(&ormLog{}, logger.Config{
		SlowThreshold: 200 * time.Millisecond,
		LogLevel:      logger.Error,
		Colorful:      false,
	})

	sqlDB, err := ormDB.DB()
	if err != nil {
		log.Error(err)
		return nil
	}

	sqlDB.SetMaxIdleConns(c.Idle)
	sqlDB.SetMaxOpenConns(c.Active)
	sqlDB.SetConnMaxLifetime(time.Duration(c.IdleTimeout))

	return ormDB
}

type ormLog struct {
}

func (l ormLog) Printf(format string, v ...interface{}) {
	log.Warnf(format, v...)
}
