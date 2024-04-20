using EBook_Models.App_Models;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;

namespace EBook_Data.DatabaseContext
{
    #region Interfaces
    public interface IEBook_DB_Context_10 : IEBook_DB_Context
    {
        public IEBook_DB_Context_10 DBContext_Instance { get; }
    }
    public interface IEBook_DB_Context_11 : IEBook_DB_Context
    {
        public IEBook_DB_Context_11 DBContext_Instance { get; }
    }
    public interface IEBook_DB_Context_13 : IEBook_DB_Context
    {
        public IEBook_DB_Context_13 DBContext_Instance { get; }
    }
    public interface IEBook_DB_Context
    {
        DbSet<T> Set<T>() where T : class;
        int Save();

        Task<int> SaveAsync();
    }
    #endregion Interfaces

    #region Interfaces Logic
    public class EBook_DB_Context_10 : EBook_DB_Context<EBook_DB_Context_10>, IEBook_DB_Context_10
    {
        public EBook_DB_Context_10(DbContextOptions<EBook_DB_Context_10> options)
        : base(options)
        {
        }

        public IEBook_DB_Context_10 DBContext_Instance
        {
            get
            {
                return this;
            }
        }

        public int Save()
        {
            return this.SaveChanges();
        }

        public async Task<int> SaveAsync()
        {
            return await this.SaveChangesAsync();
        }
    }
    public class EBook_DB_Context_11 : EBook_DB_Context<EBook_DB_Context_11>, IEBook_DB_Context_11
    {
        public EBook_DB_Context_11(DbContextOptions<EBook_DB_Context_11> options)
        : base(options)
        {
        }

        public IEBook_DB_Context_11 DBContext_Instance
        {
            get
            {
                return this;
            }
        }

        public int Save()
        {
            return this.SaveChanges();
        }

        public async Task<int> SaveAsync()
        {
            return await this.SaveChangesAsync();
        }
    }
    public class EBook_DB_Context_13 : EBook_DB_Context<EBook_DB_Context_13>, IEBook_DB_Context_13
    {
        public EBook_DB_Context_13(DbContextOptions<EBook_DB_Context_13> options)
        : base(options)
        {
        }

        public IEBook_DB_Context_13 DBContext_Instance
        {
            get
            {
                return this;
            }
        }

        public int Save()
        {
            return this.SaveChanges();
        }

        public async Task<int> SaveAsync()
        {
            return await this.SaveChangesAsync();
        }
    }
    public abstract partial class EBook_DB_Context<T> : DbContext where T : DbContext
    {
        public EBook_DB_Context(DbContextOptions<T> options)
        : base(options)
        {
        }

        #region DBSet
        [NotMapped]
        public virtual DbSet<TUser> User { get; set; } = null!;
        
        #endregion
        public int Save()
        {
            return this.SaveChanges();
        }
        public async Task<int> SaveAsync()
        {
            return await this.SaveChangesAsync();
        }
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            #region modelBuilder
            modelBuilder.Entity<TUser>(entity =>
            {
                entity.HasKey(e => e.Username);

                entity.ToTable("T_EBook_User");

                entity.Property(e => e.Otp)
                    .HasMaxLength(50)
                    .HasColumnName("OTP");

                entity.Property(e => e.OtpExpiry)
                    .HasColumnType("datetime")
                    .HasColumnName("OTP_EXPIRY");

                entity.Property(e => e.OtpStatus).HasColumnName("OTP_STATUS");

                entity.Property(e => e.Token)
                    .HasMaxLength(250)
                    .HasColumnName("TOKEN");

                entity.Property(e => e.TokenCreatedOn)
                    .HasColumnType("datetime")
                    .HasColumnName("TOKEN_CREATED_ON");

                entity.Property(e => e.TokenExpiry)
                    .HasColumnType("datetime")
                    .HasColumnName("TOKEN_EXPIRY");

                entity.Property(e => e.TokenRevokedOn)
                    .HasColumnType("datetime")
                    .HasColumnName("TOKEN_REVOKED_ON");

                entity.Property(e => e.Username).HasMaxLength(150);
            });
            #endregion

            OnModelCreatingPartial(modelBuilder);
        }
        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
    #endregion Interfaces Logic

    #region DBConnectionString
    public class GeneralDatabaseConnectionModel
    {
        public string? Server { get; set; }
        public string? Initial_Catalog { get; set; }
        public int? Port { get; set; }
        public string? Provider { get; set; }
        public string? User_Id { get; set; }
        public string? Password { get; set; }
        public string? Encrypt { get; set; } = "false";
        public string? TrustServerCertificate { get; set; } = "false";
        public bool? Integrated_Security { get; set; }
        public virtual string? ConnectionString { get; }
    }

    public class EBook_DBContextContainer
    {
        public IEBook_DB_Context_10 _context10 { get; set; }
        public IEBook_DB_Context_11 _context11 { get; set; }
        public IEBook_DB_Context_13 _context13 { get; set; }
    }

    public class EBook_DB_ConnectionModel_10 : GeneralDatabaseConnectionModel
    {
        public override string ConnectionString
        {
            get
            {
                //return $"Server={Server}; Initial Catalog={Initial_Catalog}; User Id = {User_Id}; Password = {Password}; Encrypt = {Encrypt.ToLower()}; TrustServerCertificate = {TrustServerCertificate.ToLower()};";
                return $"Server={Server}; Initial Catalog={Initial_Catalog};Integrated Security=True;TrustServerCertificate=true;";
            }
        }
    }
    public class EBook_DB_ConnectionModel_11 : GeneralDatabaseConnectionModel
    {
        public override string ConnectionString
        {
            get
            {
                return $"Server={Server}; Initial Catalog={Initial_Catalog};Integrated Security=True;TrustServerCertificate=true;";
                //return $"Server={Server}; Initial Catalog={Initial_Catalog}; User Id = {User_Id}; Password = {Password}; Encrypt = {Encrypt.ToLower()}; TrustServerCertificate = {TrustServerCertificate.ToLower()};";
            }
        }
    }
    public class EBook_DB_ConnectionModel_13 : GeneralDatabaseConnectionModel
    {
        public override string ConnectionString
        {
            get
            {
                return $"Server={Server}; Initial Catalog={Initial_Catalog}; User Id = {User_Id}; Password = {Password}; Encrypt = {Encrypt.ToLower()}; TrustServerCertificate = {TrustServerCertificate.ToLower()};";
            }
        }
    }

    public class DbStringCollection
    {
        public EBook_DB_ConnectionModel_10 EBook_DB_ConnectionModel_10 { get; set; }
        public EBook_DB_ConnectionModel_11 EBook_DB_ConnectionModel_11 { get; set; }
        public EBook_DB_ConnectionModel_13 EBook_DB_ConnectionModel_13 { get; set; }
    }
    #endregion DBConnectionString
}

