"""Add escrow fields to disputes table

This migration adds escrow functionality to the disputes table,
replacing the gambling/betting model with a legal escrow service.
"""

from alembic import op
import sqlalchemy as sa

def upgrade():
    """Add escrow fields to disputes table"""
    
    # Add escrow-related columns
    op.add_column('disputes', sa.Column('escrow_enabled', sa.Boolean(), nullable=True, default=False))
    op.add_column('disputes', sa.Column('escrow_type', sa.String(), nullable=True))
    op.add_column('disputes', sa.Column('escrow_amount', sa.Float(), nullable=True))
    op.add_column('disputes', sa.Column('escrow_status', sa.String(), nullable=True))
    op.add_column('disputes', sa.Column('escrow_data', sa.Text(), nullable=True))
    op.add_column('disputes', sa.Column('settlement_data', sa.Text(), nullable=True))
    
    # Set default values for existing records
    op.execute("UPDATE disputes SET escrow_enabled = FALSE WHERE escrow_enabled IS NULL")
    
    print("✅ Added escrow fields to disputes table")

def downgrade():
    """Remove escrow fields from disputes table"""
    
    op.drop_column('disputes', 'escrow_enabled')
    op.drop_column('disputes', 'escrow_type')
    op.drop_column('disputes', 'escrow_amount')
    op.drop_column('disputes', 'escrow_status')
    op.drop_column('disputes', 'escrow_data')
    op.drop_column('disputes', 'settlement_data')
    
    print("✅ Removed escrow fields from disputes table")

if __name__ == "__main__":
    print("""
    To run this migration:
    
    1. cd backend
    2. alembic upgrade head
    
    Or manually in Python:
    
    from database import engine
    from sqlalchemy import text
    
    with engine.connect() as conn:
        # Add columns
        conn.execute(text("ALTER TABLE disputes ADD COLUMN escrow_enabled BOOLEAN DEFAULT FALSE"))
        conn.execute(text("ALTER TABLE disputes ADD COLUMN escrow_type VARCHAR"))
        conn.execute(text("ALTER TABLE disputes ADD COLUMN escrow_amount FLOAT"))
        conn.execute(text("ALTER TABLE disputes ADD COLUMN escrow_status VARCHAR"))
        conn.execute(text("ALTER TABLE disputes ADD COLUMN escrow_data TEXT"))
        conn.execute(text("ALTER TABLE disputes ADD COLUMN settlement_data TEXT"))
        conn.commit()
    """)